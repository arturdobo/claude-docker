#!/bin/bash
set -e

# If the host Docker socket is mounted, make sure the `claude` user can reach it.
# The socket's group GID is whatever it is on the host, so match it here at runtime.
SOCK=/var/run/docker.sock
if [ -S "$SOCK" ]; then
    SOCK_GID=$(stat -c '%g' "$SOCK")
    if [ "$SOCK_GID" = "0" ]; then
        # Socket is owned by the root group; let claude in so the group bits apply.
        usermod -aG root claude
    else
        GROUP_NAME=$(getent group "$SOCK_GID" | cut -d: -f1)
        if [ -z "$GROUP_NAME" ]; then
            GROUP_NAME=docker-host
            groupadd -g "$SOCK_GID" "$GROUP_NAME"
        fi
        usermod -aG "$GROUP_NAME" claude
    fi
fi

exec gosu claude claude --dangerously-skip-permissions "$@"
