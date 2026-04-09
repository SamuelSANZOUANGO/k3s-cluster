# -*- mode: ruby -*-
# vi: set ft=ruby :

# =================================================
# Le vagrant pour déployer le cluster kubernetes
# Maintainer: Israel Samuel SANZOUANGO NOAH
# Project: Cluster kubernetes - avec ArgoCD
#  K3s + Helm + Argocd 
#====================================================
# COMPOSANT #  Minimum (LAB) #  Recommandé (Confort)
#====================================================
#  RAM      #  4Go           #   8Go
#====================================================
#  CPU      #  2vCPUs        #   4vCPUs
#====================================================
#  Disque   #  20Go          #   + de 50GO
# ===================================================

# paramètres de workers
workers = 2 
ram_worker = 1024  # Recommandé 4Go
cpu_worker = 2  # Recommandé 4vCPUs

Vagrant.configure("2") do |config|

  # Paramètres communs à toutes les machines
  config.vm.box = "bento/ubuntu-22.04"
  config.vm.boot_timeout = 600
  config.vm.box_check_update = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.ssh.insert_key = false


  #==========================================================================================================
  # ---- Workers nodes kubernetes ----
  (1..workers).each do |i|
    config.vm.define "k3s-worker#{i}" do |k3sworker|
      k3sworker.vm.hostname = "k3s-worker#{i}"
      k3sworker.vm.network "private_network", ip: "192.168.20.10#{i}"

      # Disque supplémentaire (optionnael mais recommandé)
      k3sworker.vm.disk  :disk, size: "100GB", primary: true

      k3sworker.vm.provider "virtualbox" do |v|
        v.name = "k3s-worker#{i}"
        v.cpus = cpu_worker
        v.memory = ram_worker
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        v.customize ["modifyvm", :id, "--nictype1", "virtio"]
      end

      # Provisioning 
      k3sworker.vm.provision "shell", run: "always", inline: <<-'SHELL'
        echo "[IP] $(hostname) -> $(hostname -I | awk '{print $1}')"
      SHELL

    # Provisioning du script d'installation du cluster K3s
    # k3smaster.vm.provision "shell", path: ".../install-k3s-cluster.sh"
    end
  end

  #=================================MASTER=============================================================================
  # ---- Master node kubernetes ----
  config.vm.define "k3s-master" do |k3smaster|
    k3smaster.vm.hostname = "k3s-master"
    k3smaster.vm.network "private_network", ip: "192.168.20.100"
    k3smaster.vm.disk :disk, size: "220GB", primary: true

    k3smaster.vm.provider "virtualbox" do |v|
      v.name = "k3s-master"
      v.memory = 4096
      v.cpus = 3
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      v.customize ["modifyvm", :id, "--nictype1", "virtio"]
    end
    # ➜ Affiche l'IP du worker à chaque provision
    k3smaster.vm.provision "shell", run: "always", inline: <<-'SHELL'
      echo "[IP] $(hostname) -> $(hostname -I | awk '{print $1}')"
    SHELL
    
    # Provisioning du script d'installation du cluster K3s
    # k3smaster.vm.provision "shell", path: ".../install-k3s-cluster.sh"

  end
end