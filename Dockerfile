FROM bash:latest

RUN apk add --no-cache \
    openssh-server  \
    openssh-sftp-server

ADD sshd_config /etc/ssh/sshd_config
ADD docker-entrypoint.sh .

ENTRYPOINT ["bash", "docker-entrypoint.sh"]
