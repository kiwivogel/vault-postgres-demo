Vagrant.configure(2) do |config|
  $script = <<-SCRIPT
  mkdir -p /data
  SCRIPT

  config.vm.define "sandbox" do |sandbox|
    sandbox.vm.box = "ubuntu/trusty64"
    sandbox.vm.network "private_network", ip: "192.168.32.80"

    config.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 2
    end

    config.vm.provision "shell", inline: $script
  end


end

