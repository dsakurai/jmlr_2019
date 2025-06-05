FROM debian:stable-slim
# FROM nvidia/cuda:11.0.3-base-ubuntu20.04
# Install any additional packages you need

# Purely necessary for VSCode
RUN apt update && \
    apt install -y sudo && \
    # Clean up apt cache when done
    rm -rf /var/lib/apt/lists/*

# Tools
RUN apt update && \
    apt install -y git curl vim tree && \
    # Clean up apt cache when done
    rm -rf /var/lib/apt/lists/*

# For Nix
RUN apt update && \
    apt install -y xz-utils && \
    # Clean up apt cache when done
    rm -rf /var/lib/apt/lists/*

# For VSCode
RUN adduser --disabled-password --gecos "" vscode && adduser vscode sudo

# /nix for a non-root user `vscode`. Not perfect, but OK.
RUN mkdir -p /nix && \
    chown vscode:vscode /nix && \    
    chmod 0755 /nix

USER vscode

ENV PATH="/home/vscode/.nix-profile/bin:$PATH"
