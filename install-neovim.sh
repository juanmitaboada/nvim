#!/usr/bin/env bash
#
# install-neovim.sh — one-shot bootstrap for this Neovim configuration.
#
# This script does NOT contain a copy of the config: the config *is* this
# repository. The script only does the boring plumbing:
#   1. installs the system packages the setup needs,
#   2. checks the Neovim version (the unokai colorscheme needs >= 0.10),
#   3. links this repo into ~/.config/nvim (backing up anything already there),
#   4. pre-installs plugins and reminds you of the remaining first-run steps.
#
# Debian/Ubuntu only (apt). On other distros install the same packages by hand
# (see the README) and skip straight to launching nvim.

set -euo pipefail

# ---- pretty logging -------------------------------------------------------
info() { printf '\033[1;34m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; }
die()  { err "$*"; exit 1; }

# ---- 0. sanity ------------------------------------------------------------
command -v apt-get >/dev/null 2>&1 \
    || die "This script targets Debian/Ubuntu (apt). Install the packages from the README manually."

# The repo root is wherever this script lives.
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

# ---- 1. system packages ---------------------------------------------------
#   git/make/gcc  : build telescope-fzf-native, clone plugins
#   nodejs/npm    : Copilot
#   ripgrep       : Telescope live_grep
#   fd-find       : Telescope find_files (ships as 'fdfind' on Debian/Ubuntu)
#   unzip/curl    : Mason downloads, misc
#   neovim        : the editor itself
PACKAGES=(git make gcc nodejs npm ripgrep fd-find unzip curl neovim)
info "Installing system packages: ${PACKAGES[*]}"
sudo apt-get update -qq
sudo apt-get install -y "${PACKAGES[@]}"

# Debian/Ubuntu ship fd as 'fdfind'. Telescope looks for 'fd'. Bridge it.
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    info "Linking fd -> fdfind in ~/.local/bin"
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) : ;;
        *) warn "Add ~/.local/bin to your PATH so 'fd' is picked up." ;;
    esac
fi

# ---- 2. Neovim version check ---------------------------------------------
# The config sets the builtin 'unokai' colorscheme, which only exists in 0.10+.
nvim_version="$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
nvim_minor="$(printf '%s' "$nvim_version" | cut -d. -f2)"
nvim_major="${nvim_version%%.*}"
if [ "${nvim_major:-0}" -eq 0 ] && [ "${nvim_minor:-0}" -lt 10 ]; then
    warn "Neovim $nvim_version is too old (need >= 0.10 for the unokai colorscheme)."
    warn "Install a newer build via the PPA:"
    warn "    sudo add-apt-repository ppa:neovim-ppa/unstable -y"
    warn "    sudo apt-get update && sudo apt-get install -y neovim"
    die  "Re-run this script once Neovim >= 0.10 is in place."
fi
info "Neovim $nvim_version OK."

# ---- 3. place the config --------------------------------------------------
if [ "$REPO_DIR" = "$NVIM_CONFIG" ]; then
    info "Repo already lives at $NVIM_CONFIG — nothing to link."
else
    if [ -e "$NVIM_CONFIG" ] || [ -L "$NVIM_CONFIG" ]; then
        backup="$NVIM_CONFIG.backup-$(date +%Y%m%d-%H%M%S)"
        warn "Existing $NVIM_CONFIG found — moving it to $backup"
        mv "$NVIM_CONFIG" "$backup"
    fi
    mkdir -p "$(dirname "$NVIM_CONFIG")"
    info "Linking $NVIM_CONFIG -> $REPO_DIR"
    ln -s "$REPO_DIR" "$NVIM_CONFIG"
fi

# ---- 4. pre-install plugins (best effort) --------------------------------
info "Pre-installing plugins headlessly (lazy sync)…"
if ! nvim --headless "+Lazy! sync" +qa 2>/dev/null; then
    warn "Headless plugin sync skipped — it will run on first launch instead."
fi

# ---- 5. done --------------------------------------------------------------
info "Bootstrap complete."
cat <<'EOF'

Remaining first-run steps:
  1. nvim              # Mason installs LSPs / formatters / linters
                       #   watch progress with  :Mason
  2. :Copilot setup    # authenticate Copilot (first time only)

Verify anytime with  :checkhealth
EOF
