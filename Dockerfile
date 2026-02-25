FROM debian:bookworm-slim

ARG UID

# --- GitHub CLI repository setup ---
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# --- System packages ---
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    gh \
    git \
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
    && ln -s "$(which node)" /usr/local/bin/node \
    && ln -s "$(which npm)" /usr/local/bin/npm \
    && ln -s "$(which npx)" /usr/local/bin/npx

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

RUN curl -fsSL https://claude.ai/install.sh | bash

RUN ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -q

ENTRYPOINT ["claude", "--dangerously-skip-permissions"]
