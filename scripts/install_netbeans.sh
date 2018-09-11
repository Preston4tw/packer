#!/bin/bash -x

set -o errexit
set -o nounset
set -o pipefail



[ -f "/home/vagrant/${NETBEANS_FILENAME}" ]

/home/vagrant/${NETBEANS_FILENAME} --silent

[ -f "/home/vagrant/netbeans-8.2/etc/netbeans.conf" ]

sed -i 's|^netbeans_jdkhome=.*|netbeans_jdkhome="/usr/java/latest"|' "/home/vagrant/netbeans-8.2/etc/netbeans.conf"

# Desktop is not created until after graphical login
ln -s "/home/vagrant/netbeans-8.2/bin/netbeans" "/home/vagrant/netbeans8.2_launcher"
