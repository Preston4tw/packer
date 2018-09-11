# Relevant documentation:
# RHEL 6 Kickstart Options
#   https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Installation_Guide/s1-kickstart2-options.html
# CentOS Image Standards
#   https://github.com/CentOS/ImageStandards
# Vagrant BaseBox Documentation
#   https://www.vagrantup.com/docs/boxes/base.html
# Packer Documentation
#   https://www.packer.io/docs/

# Disable the root account
rootpw vagrant
# Create a regular user
# user is given sudo in %post
user --name=vagrant --password=vagrant


# US + UTC
keyboard us
lang en_US.UTF-8
timezone --utc Etc/UTC

# Install from an attached cdrom
install
cdrom

# Do the install on the console instead of UI
cmdline
# Don't configure X
skipx
reboot
# Skip the firstboot wizard
firstboot --disabled


authconfig --passalgo=sha512

# Initialize networking and use DHCP to get an address
# Needed for %post
network --bootproto=dhcp

# Disable Firewall and SELinux
firewall --disabled
selinux --disabled

# Initialize any invalid partition tables
zerombr
# Really disable selinux
bootloader --location=mbr --append="selinux=0"

# Create a single ext4 partition covering the entire disk
clearpart --all
# part / --fstype=ext4 --grow --asprimary --size=1

part /boot --fstype ext4 --size=1024
part swap --size=8192
part pv.01  --size=1  --grow
volgroup vg00 pv.01
logvol / --vgname=vg00  --fstype=ext4  --size=1 --name=lv_root --grow

# Minimal package set
# Keep in mind the install is being done against the minimal ISO which has a
# very minimal set of packages present. Any additional software probably needs
# to be installed via yum in the %post section.
%packages --nobase --excludedocs
@core
-iscsi-initiator-utils
-device-mapper-multipath
%end

%post
# Run the post section in a subshell display it on tty3 which we switch to for
# viewing. Also tee it to /var/log/post_install.log for later review if
# necessary.
exec < /dev/tty3 > /dev/tty3
chvt 3
(
# Apply any updates available. Don't want to ship a box with known security
# vulnerabilities.
yum -y update
# Install man pages
yum -y install yum-utils man man-pages
yum -y install xorg-x11-drv-vmware

# Disable graphical boot
sed -i '/^splashimage/d' /boot/grub/grub.conf
sed -i 's/ rhgb quiet//' /boot/grub/grub.conf

# Set up the vagrant insecure key
# https://github.com/mitchellh/vagrant/tree/master/keys
sudo -u vagrant -- /bin/bash -c 'mkdir ~vagrant/.ssh && chmod 700 ~vagrant/.ssh'
sudo -u vagrant -- /bin/bash -c 'touch ~vagrant/.ssh/authorized_keys && chmod 600 ~vagrant/.ssh/authorized_keys'
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key' > ~vagrant/.ssh/authorized_keys
# Allow passwordless sudo for regular user account
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant

# Enabled reverse DNS lookups for SSH can cause slowness, disable them
echo "UseDNS no" >> /etc/ssh/sshd_config

# Disable the sudo requirement for an interactive session. Required for most
# automation that uses ssh + sudo: ansible, packer, etc
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
) 2>&1 | /usr/bin/tee /var/log/install_post.log
chvt 1
%end
