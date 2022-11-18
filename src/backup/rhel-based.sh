#!/bin/bash
# Script for use only in RHEL based OS


BINARY_PATH="https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.4/\
binary/redhat/7/x86_64/percona-xtrabackup-24-2.4.4-1.el7.x86_64.rpm"


YUM=$(which yum)
[[ -z ${YUM} ]] && { echo "INFO: Yum not found in this OS"; exit 1; }


# Install XTRABACKUP
wget ${BINARY_PATH}

sudo ${YUM} localinstall percona-xtrabackup-24-2.4.4-1.el7.x86_64.rpm -y
