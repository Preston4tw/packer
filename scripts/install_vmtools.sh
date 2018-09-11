#!/bin/bash -x

set -o errexit
set -o nounset
set -o pipefail

tar -xzvf /home/vagrant/VMwareTools-10.0.6-3595377.tar.gz
sync
sleep 5
sync
/home/vagrant/vmware-tools-distrib/vmware-install.pl -d
