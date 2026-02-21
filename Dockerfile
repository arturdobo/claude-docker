FROM debian:bookworm-slim

ARG UID

RUN apt-get update && apt-get install -y \
    jq \
    curl \
    git \
    python3 \
    python3-pip \
    ripgrep \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash -u $UID claude

ENV COLORTERM=truecolor
ENV HOME=/home/claude
ENV PATH="/home/claude/.local/bin:$PATH"

USER claude

RUN curl -fsSL https://claude.ai/install.sh | bash

ENTRYPOINT ["claude"]
CMD ["--dangerously-skip-permissions"]