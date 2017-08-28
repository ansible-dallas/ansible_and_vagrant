# -*- mode: ruby -*-
# vi: set ft=ruby :

# Require YAML module
require 'yaml'
require 'erb'

if ENV['SERVERS_OVERRIDE']
  servers_file = ENV['SERVERS_OVERRIDE']
else
  servers_file = 'servers.yml'
end

# Read YAML file with box details...
if File.exist?(servers_file)
  template = ERB.new File.new(File.join(File.dirname(__FILE__), servers_file)).read
  settings = YAML.load template.result(binding)
else
  fail "Please provide a servers.yml file"
end
servers = settings["servers"]

# install required plugins if necessary
if ARGV[0] == 'up'
  # add required plugins here
  required_plugins = %w( vagrant-winrm vagrant-hostsupdater vagrant-share vagrant-vbguest )
  missing_plugins = []
  required_plugins.each do |plugin|
      missing_plugins.push(plugin) unless Vagrant.has_plugin? plugin
  end

  if ! missing_plugins.empty?
    install_these = missing_plugins.join(' ')
    puts "Found missing plugins: #{install_these}.  Installing..."
    exec "vagrant plugin install #{install_these}; vagrant up"
  end
end

Vagrant.configure(2) do |config|
  config.vbguest.auto_update = settings["vbguest_auto_update"]

  config.vm.synced_folder ".", "/home/vagrant/sync", disabled: settings["synced_folder_home_disabled"]
  config.vm.synced_folder ".", "/vagrant", disabled: settings["synced_folder_vagrant_disabled"]

  if (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    config.vm.synced_folder ".", "/vagrant", type: "virtualbox",
      mount_options: ["dmode=700,fmode=700"],
      owner: "vagrant", group: "vagrant"
  else
    config.vm.synced_folder ".", "/vagrant", type: "virtualbox",
      mount_options: ["dmode=700,fmode=700"],
      owner: "vagrant", group: "vagrant"
  end

  servers.each do |server|
    if server["create"]
      config.vm.provision "shell", inline:
        'echo "nameserver 8.8.8.8" >> /etc/resolve.conf'

      config.vm.define server["name"] do |d|

        d.vm.box_version = "#{server["box_version"]}"
        d.vm.box = server["box_name"]
        d.vm.box_download_insecure = true

        d.vm.hostname = server["name"]
        d.vm.network "private_network", ip: settings["ip_prefix"]+server["ip"]



        if (/ansible|controller/ =~ server["name"]) != nil
          if (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
            config.vm.synced_folder "./ansible", "/opt/ansible", type: "virtualbox",
              mount_options: ["dmode=700,fmode=700"],
              owner: "vagrant", group: "vagrant"
          else
            config.vm.synced_folder "./ansible", "/opt/ansible", type: "virtualbox",
              mount_options: ["dmode=700,fmode=700"],
              owner: "vagrant", group: "vagrant"
          end
        end

        if server["forwarded_ports"]
          ports = server["forwarded_ports"]
          ports.each do |port|
            d.vm.network "forwarded_port",
              guest: port["guest"],
              host: port["host"],
              protocol: port["protocol"],
              host_ip: "127.0.0.1",
              auto_correct: true
          end
        end

        d.ssh.forward_agent = true
        d.ssh.insert_key = true

        if settings["provision_files"]
          if (/win/ =~ server["guest_os"]) == nil then
            provision_files = settings["provision_files"]
            provision_files.each do |file|
              d.vm.provision "file", source: file["src"], destination: file["dest"]
              if (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
                d.vm.provision "shell", inline: "chmod 600 #{file["dest"]};", privileged: false
              end
            end
          end
        end

        if server["ansible_playbook"] then
          playbooks = server["ansible_playbook"]
          playbooks.each do |playbook|
            d.vm.provision "playbooks", type: "shell",
              inline: "echo '\n';"
            print "Execute #{playbook['name']}? #{playbook['execute']}\n"
          end
        end

        if server["bootstrap_file"]
          d.vm.provision "bootstrap", type: "shell", path: server["bootstrap_file"], privileged: false
        end

        if server["ansible_playbook"]
          playbooks = server["ansible_playbook"]
          playbooks.each do |playbook|
            if playbook["execute"]

              d.vm.provision "ansible_local" do |ansible|
                ansible.provisioning_path = "/opt/ansible/plays"

                if playbook["playbook"]
                  ansible.playbook = "/opt/ansible/plays/#{playbook["playbook"]}"
                end

                # if playbook["inventory_path"]
                #   ansible.inventory_path = "/opt/ansible/#{playbook["inventory_path"]}"
                # end
                ansible.inventory_path = "/opt/ansible/hosts"

                if playbook["limit"]
                  ansible.limit = playbook["limit"]
                end

                if playbook["extra_vars"]
                  ansible.raw_arguments = "--extra-vars '#{playbook["extra_vars"]}'"
                end

                if playbook["vault_password_file"]
                  ansible.vault_password_file = playbook["vault_password_file"]
                end

                ansible.config_file = "/opt/ansible/plays/ansible.cfg"

                if playbook["verbose"]
                  ansible.verbose = playbook["verbose"]
                end

              end
            end
          end
        end

        d.vm.provider "virtualbox" do |v|
          v.name = server["name"]
          v.memory = server["memory"]
          v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
          v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
          v.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000 ]
        end
      end
    end
  end
end
