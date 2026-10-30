# PILA LAMP 2 NIVELES
## Configuración con Vagrant
- Box de Debian 12
- Nombre:RafaelCalvo(hostname)
- Acceso a internet
    - Apache `Sí tiene acceso a internet`
    - OtraVM `Sin acceso a internet`

## Creamos el Vagrantfile
Vamos a crear el vagrantfile para ambas maquinas

La cabezera del vagrantfile
`Vagrant.configure("2") do |config|`
`  config.vm.box = "debian/bookworm64"`

En la cabecera ponemos la imagen del debian en este caso `debian/bookworm64`

**Ahora haremos la configuración para cada maquina *mysql* y *apache* **

### Máquina MySQL
`config.vm.define "mysql" do |db|` --> Definimos la configuración de la VM
` db.vm.hostname = "RafaelCalvoRomeroMysql"` --> Indicamos el hostname que en este caso es mi nombre y el tipo de la maquina
` db.vm.network "private_network", ip: "192.168.10.11", virtualbox_intnet: "redlamp" --> Configuramos la red de la VM como red privada y indicamos el nombre de la red interna y su ip
` db.vm.provision "shell", path: "provision_mysql.sh"` --> **provision** indica que es lo que se ejecuta en la maquina nada más crearla, **shell** indica que se ejecuta en el termino bash y **path** indica la ruta del archivo a ejecutar 
` db.vm.provision "shell", run: "always", inline: "ip route del default || true"` --> Esta lina le quita el internet a MySQL
