# Claude Code in Docker

Run Claude Code in an isolated Docker container.

## Prerequisites

- Docker Desktop (API version >= 1.44)

## Setup

### 1. Build the image

```bash
docker build --build-arg UID=$(id -u) -t claude-code .
```

### 2. Initialize docker config

```bash
mkdir -p ~/.claude-docker/config
```

### 3. Run

```bash
docker run -it --rm \
  -v $(pwd):$(pwd) \
  -w $(pwd) \
  -v ~/.claude-docker/config:/home/claude/.claude \
  -v ~/.claude-docker/.claude.json:/home/claude/.claude.json \
  -v ~/.gitconfig:/home/claude/.gitconfig:ro \
  -e TERM=$TERM \
  claude-code
```

The project is mounted at its real host path (`-v $(pwd):$(pwd) -w $(pwd)`), so paths in plugin configs and project settings match between host and container.

On first run, use `/login` inside the container to authenticate with your subscription.

## Optional: Shell alias

Add to your `~/.zshrc` or `~/.bashrc` for convenience:

```bash
alias claude-docker='docker run -it --rm \
  -v $(pwd):$(pwd) \
  -w $(pwd) \
  -v ~/.claude-docker/config:/home/claude/.claude \
  -v ~/.claude-docker/.claude.json:/home/claude/.claude.json \
  -v ~/.gitconfig:/home/claude/.gitconfig:ro \
  -e TERM=$TERM \
  claude-code'
```

Then just run `claude-docker` from any project directory.

## Usage

```bash
# Start interactive session
claude-docker

# Continue last session
claude-docker --continue

# Pass a prompt directly
claude-docker -- "fix the failing tests"
```
