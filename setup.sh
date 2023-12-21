#!/bin/bash

# =====================================================
#  This script used to setup ndt
#  Part of https://github.com/wildyrando/ndt.git
# =====================================================

if ! [[ $(whoami) == "root" ]]; then
  echo "This script required sudoer"
  exit
fi

if ! command -V iptables > /dev/null 2>&1; then
  echo "iptables not installed, please install and try again !"
  exit
fi

if ! command -V ebtables > /dev/null 2>&1; then
  echo "ebtables not installed, please install and try again !"
  exit 
fi

wget -q -O /usr/bin/ndt 'https://raw.githubusercontent.com/wildyrando/ndt/main/ndt.sh'
chmod 700 /usr/bin/ndt

if ! [[ $(echo -e '7' | /usr/bin/ndt | grep -w 'Existed.') ]] then
  echo "Installation failed, please try again !"
  exit
else
  echo "Installation success,"
  echo "NDT Has been installed"
  exit
fi
