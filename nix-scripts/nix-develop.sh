#!/usr/bin/env bash
set -e

# the directory of this script
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Pass all arguments to nix develop
nix develop --extra-experimental-features nix-command --extra-experimental-features flakes "$SCRIPT_DIR" "$@"
