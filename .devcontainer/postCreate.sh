#!/usr/bin/env /bin/bash
set -e

if ! command -v nix >/dev/null 2>&1 ; then
  echo "[ENTRYPOINT] Installing Nix..."
  curl -L https://nixos.org/nix/install | sh
  echo '. "$HOME/.nix-profile/etc/profile.d/nix.sh"' >> "$HOME/.bashrc"
else
  echo "[ENTRYPOINT] Nix already installed."
fi

# Source nix for current shell
if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

