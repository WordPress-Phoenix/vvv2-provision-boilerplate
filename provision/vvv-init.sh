#!/usr/bin/env bash
# Provision WordPress Stable
DOMAIN=`get_primary_host "${VVV_SITE_NAME}".test`
DOMAINS=`get_hosts "${DOMAIN}"`
SITE_TITLE=`get_config_value 'site_title' "${DOMAIN}"`
WP_VERSION=`get_config_value 'wp_version' 'latest'`
WP_TYPE=`get_config_value 'wp_type' "single"`
DB_NAME=`get_config_value 'db_name' "${VVV_SITE_NAME}"`

# make sure jq is installed so we can use Github API to fetch latest release download urls
type foo >/dev/null 2>&1 || { echo >&2 "jq required but not installed, installing..."; apt-get install jq; }

# Make a database, if we don't already have one
echo -e "\nCreating database '${DB_NAME}' (if it's not already there)"
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME}"
mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO wp@localhost IDENTIFIED BY 'wp';"
echo -e "\n DB operations done.\n\n"

# Nginx Logs
mkdir -p ${VVV_PATH_TO_SITE}/log
touch ${VVV_PATH_TO_SITE}/log/error.log
touch ${VVV_PATH_TO_SITE}/log/access.log

# Install and configure the latest stable version of WordPress
if [[ ! -f "${VVV_PATH_TO_SITE}/public_html/wp-load.php" ]]; then
    echo "Downloading WordPress [::28]..."
	noroot wp core download --version="${WP_VERSION}"
fi

if [[ ! -f "${VVV_PATH_TO_SITE}/public_html/wp-config.php" ]]; then
  echo "Configuring WordPress [::32]..."
  noroot wp core config --dbname="${DB_NAME}" --dbuser=wp --dbpass=wp --extra-php <<'PHP'
if( ! empty( $_COOKIE['debug'] )) {
    define( 'WP_DEBUG', true );
}
PHP
  echo "Installing WordPress [::38]..."
  noroot wp core install --url="${DOMAIN}" --quiet --title="" --admin_user=admin --admin_email="admin@local.dev"
  echo 'Removing default plugins and themes'
  noroot wp theme delete twentythirteen ; noroot wp theme delete twentyfourteen; noroot wp theme delete twentyfifteen; noroot wp theme delete twentysixteen; noroot wp plugin delete hello; noroot wp plugin delete akismet;
  echo 'Importing sample data into DB...';
  zcat provision-boilerplate-11-07-2017.sql.gz | mysql -u 'wp' -pwp "${DB_NAME}"
fi


if ! $(noroot wp core is-installed); then
  echo "Installing WordPress Stable..."

  if [ "${WP_TYPE}" = "subdomain" ]; then
    INSTALL_COMMAND="multisite-install --subdomains"
  elif [ "${WP_TYPE}" = "subdirectory" ]; then
    INSTALL_COMMAND="multisite-install"
  else
    INSTALL_COMMAND="install"
  fi

  noroot wp core ${INSTALL_COMMAND} --url="${DOMAIN}" --quiet --title="${SITE_TITLE}" --admin_name=admin --admin_email="admin@local.test" --admin_password="password"
else
  echo "Updating WordPress Stable..."
  cd ${VVV_PATH_TO_SITE}/public_html
  noroot wp core update --version="${WP_VERSION}"
fi

cp -f "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf.tmpl" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
sed -i "s#{{DOMAINS_HERE}}#${DOMAINS}#" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"

# Install wp-content parts
# Install plugins
echo 'Installing plugins'
# Example of installing plugin from zip file inside the provision repo
echo 'Installing wp-oauth-server-3.4.1' && noroot wp plugin install "${VVV_PATH_TO_SITE}/provision/wp-oauth-server-3.4.1.zip"
# Example of installing plugin from a WordPress.org repository
echo 'Installing user-switching' && noroot wp plugin install user-switching
# Example of installing plugin from a Github.com repository at the latest version
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/wordpress-phoenix/wordpress-rest-cache/releases/latest | jq -r ".html_url")
DOWNLOAD_URL=${DOWNLOAD_URL/releases\/tag/archive}.zip
echo 'Installing wp-rest-cache' && noroot wp plugin install "${DOWNLOAD_URL}"
# Example of installing plugin only if it has not already been installed
if [[ ! -f "${VVV_PATH_TO_SITE}/public_html/wp-content/plugins/lil-notices/lil-notices.php" ]]; then
    #Exmple of installing a plugin from a Github.com repo
    echo 'Installing lil-notices' && noroot wp plugin install https://github.com/WordPress-Phoenix/lil-notices/archive/1.0.7.zip
fi

#echo 'Installing from private Github repo...'
#if [[ ! -f "${VVV_PATH_TO_SITE}/public_html/wp-content/.gitignore" ]]; then
#   cd "${VVV_PATH_TO_SITE}/public_html/wp-content/plugins/"
#	git clone https://${GHUSERNAME}:${GHTOKEN}@github.com/MyAccount/private-repo.git
#   git remote set-url origin https://github.com/MyAccount/private-repo.git
#fi

# Example installing a theme that has a parent theme zip file nested, assumed private here and develop GIT branch.
#if [[ ! -f "${VVV_PATH_TO_SITE}/public_html/wp-content/themes/privatechild/style.css" ]]; then
#    echo "Cloning Theme: childtheme..."
#    cd "${VVV_PATH_TO_SITE}/public_html/wp-content/themes"
#	git clone https://${GHUSERNAME}:${GHTOKEN}@github.com/MyAccount/privatechild.git
#	git -C kickoff/ checkout -b develop origin/develop
#	git -C kickoff/ remote set-url origin https://github.com/MyAccount/privatechild.git
#    echo 'Extracting parent theme' && noroot wp theme install "${VVV_PATH_TO_SITE}/public_html/wp-content/themes/privatechild/assets/parent.zip"
#fi