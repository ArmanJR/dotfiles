#!/usr/bin/env bash
# Minimal Debian / Raspberry Pi OS terminal setup. Run as the target user.
set -euo pipefail

log() { printf '[%s] %s\n' "$1" "$2" >&2; }
trap 'log ERROR "Bootstrap failed at line $LINENO (exit $?). Resolve the reported error and rerun."' ERR

if [[ "${1:-}" == --help && $# -eq 1 ]]; then
    printf 'Usage: bash linux-edge/sbc/bootstrap.sh\nInstalls basic terminal packages using apt-get, then syncs the SBC shell files.\nRequires root or non-interactive sudo access.\n'
    exit 0
fi
if [[ $# -ne 0 ]]; then
    log ERROR 'Unknown arguments (use --help).'
    exit 1
fi
if [[ "$(uname -s)" != Linux ]] || ! command -v apt-get >/dev/null 2>&1; then
    log ERROR 'This bootstrap requires Debian, Ubuntu, or Raspberry Pi OS with apt-get.'
    exit 1
fi

SBC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SUDO=()
if [[ $EUID -ne 0 ]]; then
    if ! command -v sudo >/dev/null 2>&1 || ! sudo -n true; then
        log ERROR 'Non-interactive sudo access is required to install packages.'
        exit 1
    fi
    SUDO=(sudo -n)
fi

log STEP 'Installing basic terminal packages'
"${SUDO[@]}" env DEBIAN_FRONTEND=noninteractive apt-get update
"${SUDO[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    zsh git curl ca-certificates vim-tiny less tmux htop ripgrep

bash "$SBC_DIR/sync.sh"
log OK 'Setup complete. Run exec zsh to use it; optionally set your login shell with chsh -s /usr/bin/zsh.'
