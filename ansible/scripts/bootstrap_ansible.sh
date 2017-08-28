#!/bin/bash

echo "Configuring Ansible guest... $(hostname)"

# See: https://pypi.python.org/pypi/ansible
ANSIBLE_VERSION=2.3.2.0

# check to see if:
#   ansible is installed...
#   the ansible version is correct...
if [ ! $(type ansible > /dev/null 2>&1) ] && \
   [ ! "$(ansible --version | awk -F' ' '/ansible / {print $2}')" == "$ANSIBLE_VERSION" ]; then
  echo "Installing Ansible and dependencies..."

  if command -v yum >/dev/null; then
    echo "Yum packager found."
    sudo yum -y install epel-release && sudo yum -y update
    sudo yum -y install PyYAML python-jinja2 python-httplib2 python-keyczar \
                python2-paramiko python-setuptools \
                git python-pip unzip
  elif command -v apt-get >/dev/null; then
    echo "APT packager found."
    sudo apt-get update
    sudo apt-get -y upgrade
    sudo apt-get install -y python-yaml python-jinja2 python-httplib2 python-keyczar \
                            python2-paramiko python-setuptools \
                            python-pkg-resources \
                            git python-pip unzip
  else
    echo "error: neither yum nor apt-get found!"
    exit 1;
  fi

  sudo chown -R vagrant:vagrant /opt/ansible

  sudo pip install --upgrade pip
  sudo pip install ansible==$ANSIBLE_VERSION jmespath
fi

BASH_PROFILE=/home/vagrant/.bash_profile
if grep -q 'ansible_env' $BASH_PROFILE
then
  echo "Ansible environment already set."
else
  echo "Setting Ansible environment."
  echo ". ./ansible_env.sh" >> $BASH_PROFILE;
  . $BASH_PROFILE;
fi

# TODO: Move this to box creation
if grep -q 'net.ipv4.ip_forward' /etc/sysctl.conf
then
  echo "ipv4 forwarding already set."
else
  echo "Setting ipv4 forwarding."
  sudo sysctl -w net.ipv4.ip_forward=1
  sudo sh -c 'echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf'
fi

echo "Testing Ansible and dependencies..."
cd /opt/ansible/plays
which ansible
ansible --version
ansible -i ../hosts nodes -m ping -c local
