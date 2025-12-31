FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    software-properties-common \
    && add-apt-repository --yes --update ppa:ansible/ansible \
    && apt-get install -y \
    ansible \
    python3-pip \
    sshpass \
    openssh-client \
    moreutils \
    git \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install Ansible collections for Docker management
RUN ansible-galaxy collection install \
    community.general \
    community.docker \
    ansible.posix

RUN pip3 install --no-cache-dir \
    jmespath \
    docker \
    docker-compose

WORKDIR /ansible

CMD ["/bin/bash"]
