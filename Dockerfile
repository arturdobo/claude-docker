FROM debian:bookworm-slim

ARG UID

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list > /dev/null

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    gh \
    git \
    jq \
    python3 \
    python3-pip \
    ripgrep \
    tree \
    unzip \
    wget \
    zip \
    && rm -rf /var/lib/apt/lists/*
    
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
    && . "$HOME/.nvm/nvm.sh" \
    && nvm install 24 \
    && ln -s "$(which node)" /usr/local/bin/node \
    && ln -s "$(which npm)" /usr/local/bin/npm \
    && ln -s "$(which npx)" /usr/local/bin/npx

RUN useradd -m -s /bin/bash -u $UID claude

ENV COLORTERM=truecolor
ENV HOME=/home/claude
ENV PATH="/home/claude/.local/bin:$PATH"

USER claude

RUN curl -fsSL https://claude.ai/install.sh | bash

ENTRYPOINT ["claude", "--dangerously-skip-permissions"]