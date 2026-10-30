Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"

  # Máquina MySQL
  config.vm.define "mysql" do |db|
    db.vm.hostname = "RafaelCalvoMysql"
    db.vm.network "private_network", ip: "192.168.10.11", virtualbox__intnet: "redlamp"
    db.vm.provision "shell", path: "provision_mysql.sh"
    db.vm.provision "shell", run: "always", inline: "ip route del default || true"
  end

  # Máquina Apache
  config.vm.define "apache" do |web|
    web.vm.hostname = "RafaelCalvoApache"
    web.vm.network "private_network", ip: "192.168.10.10", virtualbox__intnet: "redlamp"
    web.vm.network "forwarded_port", guest: 80, host: 8080
    web.vm.provision "shell", path: "provision_apache.sh"
  end
end
