#!/bin/bash -x

set -o errexit
set -o nounset
set -o pipefail

[ -f "/home/vagrant/${INTELLIJ_FILENAME}" ]

EXTRACTDIR="$(dirname $(tar -ztf "${INTELLIJ_FILENAME}" | head -n1))"

tar -zxf "/home/vagrant/${INTELLIJ_FILENAME}"

[ -f "/home/vagrant/${EXTRACTDIR}/bin/idea.sh" ]

# Desktop is not created until after graphical login
ln -s "/home/vagrant/${EXTRACTDIR}/bin/idea.sh" "/home/vagrant/IntelliJ_launcher"
