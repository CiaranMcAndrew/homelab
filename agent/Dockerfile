FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    apt-transport-https \
    ca-certificates \
    moreutils \
    curl \
    gnupg \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i 's/^hosts:.*/hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4/' /etc/nsswitch.conf
    
# Install OpenTofu
COPY install-tofu.sh /install-tofu.sh
RUN chmod +x /install-tofu.sh \
    && /install-tofu.sh \
    && tofu --version \
    && rm /install-tofu.sh

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh 
ENTRYPOINT ["/entrypoint.sh"]