#!/bin/bash

echo "Configuring non-Ansible guest... $(hostname)"

if command -v yum >/dev/null; then
  echo "Yum packager found."
  sudo yum -y install epel-release && sudo yum -y update
  sudo yum -y install git unzip
elif command -v apt-get >/dev/null; then
  echo "APT packager found."
  sudo apt-get update
  sudo apt-get -y upgrade
  sudo apt-get install -y git unzip
else
  echo "error: neither yum nor apt-get found!"
  exit 1;
fi

# TODO: Move this to base box creation
if grep -q 'net.ipv4.ip_forward' /etc/sysctl.conf
then
  echo "ipv4 forwarding already set."
else
  echo "Setting ipv4 forwarding."
  sudo sysctl -w net.ipv4.ip_forward=1
  sudo sh -c 'echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf'
fi
