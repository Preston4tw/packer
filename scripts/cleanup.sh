#!/bin/bash -x

# Remove any older kernels present. Should remove the kernel from the minimal
# ISO as we run yum update in %post.
package-cleanup --oldkernels --count=1 -y
# Remove all yum cache files to reduce image size
yum -y clean all

# Remove hardware specific udev rules so hardware is properly initialized when
# being instantiated on new hardware. Without this networking can fail to come
# up as the eth0 MAC address should have changed.
rm -f /etc/udev/rules.d/70-*.rules
# Remove other references to hardware specific things with repsect to networking
# to ensure networking comes up properly on image instantiation.
sed -i /HWADDR/d /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i /UUID/d   /etc/sysconfig/network-scripts/ifcfg-eth0

# https://github.com/CentOS/ImageStandards
#   ".bash_history should be empty in all accounts."
awk -F: '{print $6}' /etc/passwd | while read home_directory; do
  bash_history_file="${home_directory}/.bash_history"
  [ -f "${bash_history_file}" ] && rm -f "${bash_history_file}"
done

# Stop services that log before clearing logfiles
service postfix stop
service rsyslog stop

# Truncate logfiles
rm -f \
  /var/log/anaconda* \
  /root/anaconda-ks.cfg \
  /root/install*.log*
echo -n | tee \
  /var/log/{cron,dmesg,dracut.log,lastlog,maillog,messages,secure,wtmp,yum.log}

# Cleanup /tmp
rm -rf /tmp/* /tmp/.[^.]+
