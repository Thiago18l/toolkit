#!/bin/bash
# Script for use only in UBuntu based OS


BINARY_PATH="wget https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.20/\
binary/debian/stretch/x86_64/percona-xtrabackup-24_2.4.20-1.stretch_amd64.deb"


APT=$(which apt)
[[ -z ${APT} ]] && { echo "INFO: Yum not found in this OS"; exit 1; }


# Install XTRABACKUP
wget ${BINARY_PATH}

sudo ${APT} install percona-xtrabackup-24_2.4.20-1.stretch_amd64.deb -y
