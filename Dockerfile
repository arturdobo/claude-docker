FROM debian:bookworm-slim

ARG UID

# --- Prerequisites for fetching apt repo keyrings ---
RUN apt-get update && apt-get install -y ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

# --- GitHub CLI repository setup ---
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# --- Docker CLI repository setup ---
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null

# --- System packages ---
RUN apt-get update && apt-get install -y \
    awscli \
    build-essential \
    curl \
    docker-ce-cli \
    docker-buildx-plugin \
    docker-compose-plugin \
    gh \
    git \
    gosu \
    jq \
    python3 \
    python3-pip \
    openssh-client \
    ripgrep \
    tree \
    unzip \
    wget \
    zip \
    && rm -rf /var/lib/apt/lists/*

# --- Node.js (via nvm) ---
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
    && . "$HOME/.nvm/nvm.sh" \
    && nvm install 24 \
    && npm install -g pnpm \
    && ln -s "$(which node)" /usr/local/bin/node \
    && ln -s "$(which npm)" /usr/local/bin/npm \
    && ln -s "$(which npx)" /usr/local/bin/npx \
    && ln -s "$(which pnpm)" /usr/local/bin/pnpm

# --- Rust (via rustup) ---
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH="/usr/local/cargo/bin:$PATH"
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path \
    && rustup component add rustfmt clippy \
    && chmod -R a+rx $RUSTUP_HOME $CARGO_HOME

# --- Claude Code ---
ARG GID
RUN useradd -m -s /bin/bash -u $UID -g $GID claude

ENV COLORTERM=truecolor
ENV PATH="/home/claude/.local/bin:$PATH"

USER claude


RUN ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -q

RUN mkdir -p /home/claude/.aws

ARG CACHEBUST
RUN curl -fsSL https://claude.ai/install.sh | bash

# Start as root so the entrypoint can align the mounted Docker socket's group,
# then drop back to the claude user via gosu.
USER root
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
