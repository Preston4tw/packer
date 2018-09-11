#!/bin/bash -x

cat <<WANdisco-svn1.9 > /etc/yum.repos.d/WANdisco-svn1.9.repo
[WANdisco-svn19]
name=WANdisco SVN Repo 1.9 - \$basearch
enabled=1
baseurl=http://opensource.wandisco.com/rhel/6/svn-1.9/RPMS/\$basearch/
gpgcheck=1
gpgkey=http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
WANdisco-svn1.9

yum -y install subversion.x86_64 subversion-perl subversion-python subversion-tools
