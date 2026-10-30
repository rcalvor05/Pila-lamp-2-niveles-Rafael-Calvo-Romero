#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y mariadb-server git
sed -i 's/^bind-address.*/bind-address = 192.168.10.11/' /etc/mysql/mariadb.conf.d/50-server.cnf
systemctl restart mariadb
rm -rf /tmp/app
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /tmp/app
mysql < /tmp/app/db/database.sql
mysql -e "CREATE USER IF NOT EXISTS" 'lamp_user'@'192.168.10.%' IDENTIFIED BY 'lamp_password';"
