# Stage 1: Base
FROM nvidia/cuda:12.2.2-base-ubuntu22.04 as base

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=on \
    SHELL=/bin/bash \
    TZ=UTC

USER root

# Install dependencies
RUN apt update && apt install -y \
    curl \
    debian-keyring \
    debian-archive-keyring \
    apt-transport-https \
    python3 \
    git \
    wget \
    python3-pip \
    gettext \
    unzip \
    tzdata && \
    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    rm -rf /var/lib/apt/lists/*

# Stage 2: Install SD tools
FROM base as setup

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Caddy
RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg && \
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list && \
    apt update && apt install -y caddy

# Install srun CLI
WORKDIR /opt/srun
RUN curl -L https://github.com/codechips/srun/releases/download/v0.3.3/srun_linux_amd64.tar.gz | tar xz && \
    chmod +x srun

# Install Filebrowser
RUN curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash
RUN mkdir /workspace

# Copy app files
COPY start.sh /start.sh
COPY config/caddy/Caddyfile.template /root/Caddyfile.template

# Copy static files for the root page
COPY static/index.html /root/static/index.html

RUN chmod +x /start.sh

EXPOSE 80

WORKDIR /

ENTRYPOINT ["/bin/bash", "start.sh"]
# CMD ["/start.sh"]
