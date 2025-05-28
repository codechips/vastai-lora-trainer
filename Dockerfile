FROM ubuntu:20.04

# Set environment variables globally to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install dependencies
RUN apt update && apt install -y \
    curl \
    debian-keyring \
    debian-archive-keyring \
    apt-transport-https \
    python3 \
    python3-pip \
    gettext \
    tzdata && \
    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    rm -rf /var/lib/apt/lists/*

# Install Caddy
RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg && \
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list && \
    apt update && apt install -y caddy

# Install srun CLI
WORKDIR /opt/srun
RUN curl -L https://github.com/codechips/srun/releases/download/v0.2.3/srun_linux_amd64.tar.gz | tar xz && \
    chmod +x srun

# Install Filebrowser
RUN curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

# Copy app files
COPY start.sh /start.sh
COPY config/caddy/Caddyfile.template /Caddyfile.template
COPY config/filebrowser/filebrowser.json /root/.filebrowser.json
COPY login_app.py /opt/login/app.py

RUN filebrowser config init

RUN chmod +x /start.sh

EXPOSE 80 443

WORKDIR /

ENTRYPOINT ["/bin/bash", "start.sh"]
# CMD ["/start.sh"]
