# PILA LAMP 2 NIVELES
## Configuración con Vagrant
- Box de Debian 12
- Nombre: RafaelCalvo (hostname)
- Acceso a Internet
    - Apache: `Sí tiene acceso a Internet`
    - Otra VM: `Sin acceso a Internet`

## Creamos el Vagrantfile
Vamos a crear el Vagrantfile para ambas máquinas.

La cabecera del Vagrantfile:

`Vagrant.configure("2") do |config|`

`config.vm.box = "debian/bookworm64"`

En la cabecera ponemos la imagen de Debian, en este caso `debian/bookworm64`.

**Ahora haremos la configuración para cada máquina: *mysql* y *apache***

### Máquina MySQL

`config.vm.define "mysql" do |db|` --> Definimos la configuración de la VM.

`db.vm.hostname = "RafaelCalvoMysql"` --> Indicamos el hostname, que en este caso es mi nombre y el tipo de la máquina.

`db.vm.network "private_network", ip: "192.168.10.11", virtualbox__intnet: "redlamp"` --> Configuramos la red de la VM como red privada e indicamos el nombre de la red interna y su IP.

`db.vm.provision "shell", path: "provision_mysql.sh"` --> **provision** indica lo que se ejecuta en la máquina nada más crearla, **shell** indica que se ejecuta en la terminal bash y **path** indica la ruta del archivo a ejecutar.

`db.vm.provision "shell", run: "always", inline: "ip route del default || true"` --> Esta línea le quita Internet a MySQL. Vagrant siempre añade un adaptador NAT, que no se puede quitar porque Vagrant lo usa para conectarse por SSH. `ip route del default` borra la ruta por defecto.

### Máquina Apache

`config.vm.define "apache" do |web|` --> Define la segunda máquina; `apache` es el nombre que usa Vagrant.

`web.vm.hostname = "RafaelCalvoApache"` --> El hostname de la máquina.

`web.vm.network "private_network", ip: "192.168.10.10", virtualbox__intnet: "redlamp"` --> La conecta a la misma red interna `redlamp` que MySQL, con la IP 192.168.10.10. Al compartir red, las 2 máquinas pueden comunicarse.

`web.vm.network "forwarded_port", guest: 80, host: 8080` --> Reenvío de puertos.

`web.vm.provision "shell", path: "provision_apache.sh"` --> Igual que en MySQL: al crear la máquina se ejecuta el script `provision_apache.sh`.

**Esta máquina conserva su acceso a Internet por el NAT.**


### Creamos el archivo provision_mysql.sh

creamos el fichero con un cualquier editor de texto
ponemos este contenido


`#!/bin/bash` ⟶ Indica que el script se ejecuta con bash.

`set -e` ⟶ Si algún comando falla, el script se detiene y no sigue con errores.

`export DEBIAN_FRONTEND=noninteractive` ⟶ Evita que la instalación de paquetes se pare a hacer preguntas, ya que nadie va a responderlas.

`apt-get update` ⟶ Actualiza la lista de paquetes disponibles.

`apt-get install -y mariadb-server git` ⟶ Instala MariaDB (en Debian 12 sustituye a MySQL y es compatible) y git para descargar la aplicación. `-y` acepta la instalación automáticamente.

`sed -i 's/^bind-address.*/bind-address = 192.168.10.11/' ...50-server.cnf` ⟶ Por defecto MariaDB solo acepta conexiones desde la propia máquina (127.0.0.1). Con `sed` cambiamos en su archivo de configuración la línea `bind-address` para que escuche en su IP de la red interna y Apache pueda conectarse.

`systemctl restart mariadb` ⟶ Reinicia MariaDB para aplicar el cambio.

`rm -rf /tmp/app` ⟶ Borra una posible copia anterior de la aplicación, para que el `git clone` no falle si se vuelve a aprovisionar.

`git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /tmp/app` ⟶ Descarga la aplicación. Se hace en este momento porque la máquina todavía tiene Internet; después se le quita.

`mysql < /tmp/app/db/database.sql` ⟶ Ejecuta el script SQL de la aplicación, que crea la base de datos y la tabla de usuarios.

`mysql -e "CREATE USER IF NOT EXISTS 'lamp_user'@'192.168.10.%' IDENTIFIED BY 'lamp_password';"` ⟶ Crea el usuario que usará la aplicación para conectarse. Con `192.168.10.%` solo puede conectarse desde la red interna, es decir, desde Apache.

`mysql -e "GRANT ALL PRIVILEGES ON lamp_db.* TO 'lamp_user'@'192.168.10.%';"` ⟶ Da permisos a ese usuario solo sobre la base de datos de la aplicación.

`mysql -e "FLUSH PRIVILEGES;"` ⟶ Recarga los permisos para que se apliquen inmediatamente.


### Creamos el archivo provision_apache.sh

```bash
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
```

`#!/bin/bash` --> Indica que el script se ejecuta con bash.

`set -e` --> Si algún comando falla, el script se detiene.

`export DEBIAN_FRONTEND=noninteractive` --> Evita que la instalación de paquetes se pare a hacer preguntas.

`apt-get update` --> Actualiza la lista de paquetes disponibles.

`apt-get install -y apache2 php libapache2-mod-php php-mysql git` --> Instala Apache (servidor web), PHP, el módulo que permite a Apache ejecutar PHP, la extensión para que PHP se conecte a MySQL/MariaDB, y git para descargar la aplicación.

`rm -rf /tmp/app` --> Borra una posible copia anterior de la aplicación para que el `git clone` no falle.

`git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /tmp/app` --> Descarga la aplicación.

`rm -f /var/www/html/index.html` --> Borra la página de bienvenida que trae Apache por defecto, para que se muestre la aplicación.

`cp -r /tmp/app/src/* /var/www/html/` --> Copia el código de la aplicación a `/var/www/html`, la carpeta que sirve Apache.

### Ajustes en la aplicación

El archivo `config.php` de la aplicación viene preparado para tener la base de datos en la misma máquina (`localhost`) y con valores de ejemplo. Como la base de datos está en otra máquina, lo modificamos con `sed`:

`sed -i "s/define('DB_HOST'.*/...` --> Cambiamos `localhost` por la IP de la máquina MySQL (192.168.10.11).

`sed -i "s/define('DB_NAME'.*/...` --> Ponemos el nombre de la base de datos que crea el script SQL de la aplicación.

`sed -i "s/define('DB_USER'.*/...` --> Ponemos el usuario creado en la máquina MySQL.

`sed -i "s/define('DB_PASSWORD'.*/...` --> Ponemos la contraseña de ese usuario.

`chown -R www-data:www-data /var/www/html` --> Hace propietario de los archivos al usuario `www-data`, que es con el que se ejecuta Apache.

`systemctl restart apache2` --> Reinicia Apache para aplicar todos los cambios.
