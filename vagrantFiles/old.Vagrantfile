# -*- mode: ruby -*-
# vi: set ft=ruby :
# Copyright 2019-2021 Tero Karvinen http://TeroKarvinen.com

$tscript = <<TSCRIPT
set -o verbose
apt-get update
apt-get -y install tree
echo "Done - set up test environment - https://terokarvinen.com/search/?q=vagrant"
TSCRIPT

Vagrant.configure("2") do |config|
    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.synced_folder "shared/", "/home/vagrant/shared", create: true
    config.vm.provision "shell", inline: $tscript
    config.vm.box = "debian/bullseye64"

    config.vm.define "t001" do |t001|
        t001.vm.hostname = "t001"
        t001.vm.network "private_network", ip: "192.168.56.0"
    end
    
    config.vm.define "t002", primary: true do |t002|
        t002.vm.hostname = "t002"
        t002.vm.network "private_network", ip: "192.168.56.0"
    end
  
end
