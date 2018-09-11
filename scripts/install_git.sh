#!/bin/bash -x

cat <<WANdisco-git > /etc/yum.repos.d/WANdisco-git.repo
[WANdisco-git]
name=WANdisco Distribution of git
baseurl=http://opensource.wandisco.com/rhel/\$releasever/git/\$basearch
enabled=1
gpgcheck=1
gpgkey=http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
WANdisco-git

yum -y install git
