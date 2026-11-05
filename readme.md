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
