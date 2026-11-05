#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y apache2 php libapache2-mod-php php-mysql git

rm -rf /tmp/app
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /tmp/app
rm -f /var/www/html/index.html
cp -r /tmp/app/src/* /var/www/html/

sed -i "s/define('DB_HOST'.*/define('DB_HOST', '192.168.10.11');/" /var/www/html/config.php
sed -i "s/define('DB_NAME'.*/define('DB_NAME', 'lamp_db');/" /var/www/html/config.php
sed -i "s/define('DB_USER'.*/define('DB_USER', 'lamp_user');/" /var/www/html/config.php
sed -i "s/define('DB_PASSWORD'.*/define('DB_PASSWORD', 'lamp_password');/" /var/www/html/config.php

chown -R www-data:www-data /var/www/html
systemctl restart apache2
