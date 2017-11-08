# VVV2 Provision Boilerplate
VVV provision repo boilerplate. Intended to be downloaded/forked.

## Pre-requisites
1. Vagrant (install with brew, see local wordpress guide below)
2. [VirtualBox](https://www.virtualbox.org/manual/ch02.html#idm858) or [Paralells](http://www.parallels.com/products/desktop/)
3. [VVV for Vagrant](https://github.com/Varying-Vagrant-Vagrants/VVV)

If you need any direction towards getting your Mac setup for development, please see the [Local WordPress Development Guide](https://github.com/WordPress-Phoenix/local-wordpress-development)

### Quick Setup for those without VVV
Make sure you have Vagrant and VirtualBox installed first. After this initial provision you can follow [Installation](#intallation) guide

```bash
mkdir -p ~/Sites; cd ~/Sites && git clone https://github.com/Varying-Vagrant-Vagrants/VVV.git ; cd VVV &&  vagrant up --provision && cp VVV/vvv-config.yml VVV/vvv-custom.yml ;
```

Note that this will copy the vvv-config.yml file for you and you can skip step 1 of the installation.

## Installation (Public Repos)

1. Copy the YML config file (VVV/vvv-config.yml) to VVV/vvv-custom.yml.
2. Paste in the following just *above* the `utilities:` section:
```yml
  # Repo sets up project installer, hosts creates host file entries, and custom is used to authorize you on Github.
  mystaging.dev:
    repo: https://github.com/WordPress-Phoenix/vvv2-provision-boilerplate
    hosts:
      - mystaging.dev
```
3. Open CLI bash interface at VVV root and paste the following:
```bash
vagrant halt; vagrant up --provision-with site-provision-boilerplate.dev
```
4. Open your project in PHPStorm (or choice IDE) at VVV, notice your new site in www/provision-boilerplate.dev, and visit your local development site at provision-boilerplate.dev to begin developing.

## Installation (Private Repos)

1. Copy the YML config file (VVV/vvv-config.yml) to VVV/vvv-custom.yml.
2. Paste in the following just *above* the `utilities:` section replacing the urls and credentials with those relative to your project:
```yml
  # Repo sets up project installer, hosts creates host file entries, and custom is used to authorize you on Github.
  provision-boilerplate.dev:
    repo: https://USERNAME:TOKEN@github.com/TimeInc/vvv2-provision-boilerplate
    hosts:
      - provision-boilerplate.dev
    custom:
      ghusername: USERNAME
      ghtoken: TOKEN
```
3. Visit https://github.com/settings/tokens and click `generate new token`.
4. Name your token `temp-vvv2-provision` and check the checkbox next to `repo`, then click the green `generate token` button at the bottom.
5. Replace the `USERNAME` and `TOKEN` sections with your github username and *temporary* personal access token. (Please read the [security section](#security) for more details.)
6. Open CLI bash interface at VVV root and paste the following:
```bash
vagrant halt; vagrant up --provision-with site-provision-boilerplate.dev
```
7. After the provision is completed, delete or regenerate your personal access token. *Do not skip this step!!*
8. Open your project in PHPStorm (or other choice IDE) at VVV, notice your new site in www/provision-boilerplate.dev, and visit your local development site at provision-boilerplate.dev to begin developing.

## Security

The repositories required for TimeSpringboard locally are private. As such, a username and token are required to build the provision. Thankfully, tokens are ephemeral, so we can create and destroy them at will. As such, part of the installation will walk you through creating your personal access token and then recommends deleting or regenerating the access token. Using tokens in plain text is a known bad practice, but immediately revoking the access after its used allows us to use this method. 

It may also be wise to delete the token out of your YML config file as well, although this is required because the token will no longer be affective if you have regenerated or deleted that access token.

Be safe out there!

## Utility bash commands

### Uninstall or Remove the provision

```bash
bash ~/Sites/VVV/www/provision-boilerplate.dev/remove-provision.sh
```
