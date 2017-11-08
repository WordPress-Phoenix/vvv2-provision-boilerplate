#!/usr/bin/env bash
vagrant ssh -c "mysqladmin -f -uwp -pwp drop pethero"
rm -rf ~/Sites/VVV/www/pethero.dev/
