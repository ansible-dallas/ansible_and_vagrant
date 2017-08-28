# Ansible Local Development Framework
This repository will contain the base Ansible and Vagrant development
framework that will allow us to do Infrastructure as Code (IaC),
locally (laptop/workstation), and on remote nodes (physical, virtual,
or on a cloud).

## Requirements
* A clone of this repository (ansible_and_vagrant) on your local
    workstation:  (the path to where you keep your git workspaces
    will be referenced below as 'git workspace')

  ```
    $ cd 'git workspace'
    $ git clone https://github.com/ansible-dallas/ansible_and_vagrant.git
  ```

## Steps (commands via Git-Bash, if on windows terminal session):

### Create a servers.yml file that is symbolically linked to your
servers' yaml file:
  (example below is creating a servers.yml symbic link to the
  servers_ansible_vagrant.yml file)

```
$ cd ansible_and_vagrant
$ ln -s -T servers_ansible_vagrant.yml servers.yml
```

  Do not 'git add' the servers.yml (the symbolic link) file into the git
  'code base'.  It is only for local development use, and will cause
  other users problems. Jus in case, I have added 'servers.yml' to the
  root .gitignore list.


### Start the guest machines and SSH into the Ansible controller guest VM:
  (I usually keep two terminal sessions running; one for the host related
  vagrant commands, the other for the guest VM related commands):

```
$ # Make sure to change directory into the cloned source code's path:
$ cd 'git workspace'/ansible_and_vagrant

$ # Check the status all of the VirtualBox guest VMs (test and controller):
$ vagrant status

$ # Start all of the VirtualBox guest VMs (test and controller):
$ vagrant up
```

### FYI...
  At this point, Vagrant will provision the test CentOS guest VM,
  then provision the controller CentOS guest VM.  Ansible has to be
  provisioned last, as it will in turn provision the needed
  applications/configurations on the other VM(s).  Prior to provisioning
  the other VM(s), Ansible and its dependencies will be provisioned via
  a Vagrant shell bootstrap file.  Once Ansible is available, it will
  run a test Ansible playbook against the two guest VMs.

  When you get to this point, you should have two fully functional CentOS 7
  guest VMs.  One for the Ansible controller, and the other for Ansible to
  use for running 'tests' against (test).


### Get information from within the Ansible controller guest VM:

```
$ # SSH into the Ansible controller guest VirtualBox VM:
$ vagrant ssh ansible

$ # Get the present working directory:
$ pwd

$ # Get the user that I'm running as:
$ whoami

$ # Get the Ansible controller guest VirtualBox VM's host name:
$ hostname

```

### Get information on the Anible runtime:

```
$ # Change directory into where the Ansible adhoc or playbooks
$ # commands will be executed from (ansible.cfg file lives here.
$ # read up on ansible.cfg):
$ cd /opt/ansible/plays

$ # Check to see that the ansible command line binary is available:
$ which ansible

$ # Check the Ansible run time (binary) version:
$ ansible --version

```

### Execute Ansible (adhoc) and Ansible playbook commands:

```
$ # See if Ansible can contact itself (via the Ansible ping module):
$ ansible -i ../hosts localhost -m ping -c local

$ # See if Ansible can contact all nodes within the nodes group
$ # (see host inventory file):
$ ansible -i ../hosts nodes -m ping

$ # Read what is in the inventory file that is passed via the Ansible
$ # command line:
$ vi ../hosts

$ # See all the Ansible facts that are associated with the localhost
$ # guest VM (controller):
$ # VirtualBox VM (controller):
$ ansible -i ../hosts localhost -m setup

$ # See all the Ansible facts that are associated with the test guest
$ # VM:
$ ansible -i ../hosts test -m setup

```

## FYI..
* The Ansible version that is provisioned is controlled within the
  ansible/scripts/bootstrap_ansible.sh file (search for: ANSIBLE_VERSION)
* After changing the ANSIBLE_VERSION version, from within the
  'git workspace'/ansible_and_vagrant execute:
  ```
  $ vagrant provision --provision-with bootstrap controller
  ```


# To do:
* Who knows?
* Tutorial on Ansible
* Tutorial on Vagrant
* Tutorial on Ansible adhoc commands
* Tutorial on Ansible modules
* Tutorial on creating Ansible roles

Happy 'Infrastructure as Code' coding!

