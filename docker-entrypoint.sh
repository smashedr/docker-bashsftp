#!/usr/bin/env bash

set -e

if [[ -z "${SFTP_PASS}" ]];then
    echo "No SFTP_PASS provided. Aborting for security."
    exit 1
fi

[[ -z "${SFTP_USER}" ]] && SFTP_USER="ftpuser"
[[ -z "${SFTP_HOME}" ]] && SFTP_HOME="/data"
[[ -z "${SFTP_PORT}" ]] && SFTP_PORT="2222"

if [[ ! -f /etc/ssh/ssh_host_rsa_key ]]; then
    ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ''
fi
if [[ ! -f /etc/ssh/ssh_host_ecdsa_key ]]; then
    ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
fi
if [[ ! -f /etc/ssh/ssh_host_ed25519_key ]]; then
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''
fi

if [[ "${SFTP_PORT}" != "2222" ]];then
    sed -i "s/Port 2222/Port ${SFTP_PORT}/" /etc/ssh/sshd_config
fi

if ! id -u "${SFTP_HOME}" >/dev/null 2>&1;then
    adduser -D -H -h "${SFTP_HOME}" -G root "${SFTP_USER}"
fi
if [[ "${SFTP_PASS:0:3}" = '$6$' ]];then
    sed -i "s/${SFTP_USER}:!/${SFTP_USER}:${SFTP_PASS}/" /etc/shadow
else
    echo "${SFTP_USER}:${SFTP_PASS}" | chpasswd
fi

/usr/sbin/sshd -D -e
