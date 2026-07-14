#!/usr/bin/env bash
#
# install-neovim.sh — one-shot bootstrap for this Neovim configuration.
#
# This script does NOT contain a copy of the config: the config *is* this
# repository. The script only does the boring plumbing:
#   1. checks what (if anything) is actually missing — nothing to install
#      means the whole sudo/apt phase is skipped,
#   2. checks the Neovim version (the unokai colorscheme needs >= 0.10),
#   3. links this repo into ~/.config/nvim (backing up anything already there),
#   4. pre-installs plugins and reminds you of the remaining first-run steps.
#
# It is sudo-optional. If something needs installing but you can't escalate
# (no sudo, or you're not a sudoer), the script prints the exact commands an
# administrator has to run and — as long as Neovim itself is usable — offers
# to finish configuring the rest anyway. If Neovim is missing it stops: this
# whole script exists to set up Neovim, so there is nothing to do without it.
#
# Debian/Ubuntu oriented (apt). On other distros install the same packages by
# hand (see the README) and re-run.

set -euo pipefail

# ---- pretty logging -------------------------------------------------------
info() { printf '\033[1;34m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; }
die()  { err "$*"; exit 1; }

# ---- helpers: privileges & packages --------------------------------------
# Run a command with root privileges, however we can:
#   already root -> run it directly
#   sudo present -> prefix with sudo (may prompt for a password)
#   neither      -> return 127 so the caller can fall back to manual commands.
priv_run() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        return 127
    fi
}

# Map an apt package name to the command it provides, so we can detect what is
# already installed without touching apt/dpkg (and without needing sudo).
pkg_command() {
    case "$1" in
        nodejs)  echo node   ;;
        ripgrep) echo rg     ;;
        fd-find) echo fdfind ;;
        neovim)  echo nvim   ;;
        *)       echo "$1"   ;;
    esac
}

# Is Neovim present AND >= 0.10 (needed for the builtin unokai colorscheme)?
# Sets NVIM_VERSION on success.
NVIM_VERSION=""
nvim_good() {
    command -v nvim >/dev/null 2>&1 || return 1
    local v maj min
    v="$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
    [ -n "$v" ] || return 1
    NVIM_VERSION="$v"   # record whatever we found, good or not, for messaging
    maj="${v%%.*}"
    min="$(printf '%s' "$v" | cut -d. -f2)"
    if [ "${maj:-0}" -eq 0 ] && [ "${min:-0}" -lt 10 ]; then
        return 1
    fi
    return 0
}

# ---- 0. where does the repo live -----------------------------------------
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

# ---- 1. figure out what is missing (no sudo, no apt yet) ------------------
#   git/make/gcc  : build telescope-fzf-native, clone plugins
#   nodejs/npm    : Copilot
#   ripgrep       : Telescope live_grep
#   fd-find       : Telescope find_files (ships as 'fdfind' on Debian/Ubuntu)
#   unzip/curl    : Mason downloads, misc
HELPER_PKGS=(git make gcc nodejs npm ripgrep fd-find unzip curl)

MISSING_PKGS=()
for pkg in "${HELPER_PKGS[@]}"; do
    if ! command -v "$(pkg_command "$pkg")" >/dev/null 2>&1; then
        MISSING_PKGS+=("$pkg")
    fi
done

# Neovim state: good | old | absent.
if command -v nvim >/dev/null 2>&1; then
    if nvim_good; then nvim_state=good; else nvim_state=old; fi
else
    nvim_state=absent
fi

# ---- 2. install only what's actually missing -----------------------------
# Bundle the helper packages with neovim (only if it's entirely absent) into a
# single apt run, so we escalate at most once.
INSTALL_PKGS=("${MISSING_PKGS[@]}")
[ "$nvim_state" = absent ] && INSTALL_PKGS+=(neovim)

if [ "${#INSTALL_PKGS[@]}" -eq 0 ] && [ "$nvim_state" != old ]; then
    info "All required packages are already installed — skipping apt/sudo."
elif [ "${#INSTALL_PKGS[@]}" -gt 0 ]; then
    if ! command -v apt-get >/dev/null 2>&1; then
        warn "apt-get not found on this system — cannot install automatically."
        : # nothing installed; STILL_MISSING / nvim_state below drive the decision
    else
        info "Missing packages: ${INSTALL_PKGS[*]}"
        info "Trying to install them with administrator privileges…"
        if priv_run sh -c 'apt-get update -qq && apt-get install -y "$@"' sh "${INSTALL_PKGS[@]}"; then
            info "Packages installed."
        else
            warn "Could not install with administrator privileges (no sudo, or not permitted)."
            : # nothing installed; STILL_MISSING / nvim_state below drive the decision
        fi
    fi
fi

# Re-check Neovim in case we just installed it (also refreshes NVIM_VERSION).
if nvim_good; then nvim_state=good; fi

# Recompute the helper packages that are STILL missing after the attempt.
STILL_MISSING=()
for pkg in "${HELPER_PKGS[@]}"; do
    command -v "$(pkg_command "$pkg")" >/dev/null 2>&1 || STILL_MISSING+=("$pkg")
done

# ---- 3. Neovim is mandatory: no Neovim -> stop, don't offer anything ------
if [ "$nvim_state" != good ]; then
    if [ "$nvim_state" = old ]; then
        err "Neovim ${NVIM_VERSION:-} is too old (need >= 0.10 for the unokai colorscheme)."
    else
        err "Neovim is not installed."
    fi
    echo
    warn "Run the following as an administrator, then re-run this script:"
    if [ "${#STILL_MISSING[@]}" -gt 0 ]; then
        echo "    sudo apt-get update"
        echo "    sudo apt-get install -y ${STILL_MISSING[*]}"
    fi
    # apt's neovim is often < 0.10, so point at the PPA for a current build.
    echo "    sudo add-apt-repository ppa:neovim-ppa/unstable -y"
    echo "    sudo apt-get update && sudo apt-get install -y neovim"
    echo
    die "This script only sets up Neovim — nothing to do until Neovim (>= 0.10) is available."
fi

info "Neovim ${NVIM_VERSION} OK."

# ---- 4. helper packages missing but not installable: ask before going on --
if [ "${#STILL_MISSING[@]}" -gt 0 ]; then
    warn "These packages could not be installed and need an administrator:"
    echo "    sudo apt-get update"
    echo "    sudo apt-get install -y ${STILL_MISSING[*]}"
    echo
    warn "Neovim itself is fine, so the rest of the setup can still run."
    warn "The missing packages only gate some features:"
    warn "  ripgrep/fd-find -> Telescope search · nodejs/npm -> Copilot · gcc/make -> native builds"
    echo
    if [ -t 0 ]; then
        read -r -p ":: Finish configuring the rest now (config link + plugin sync)? [y/N] " reply
    else
        reply="y"
        warn "Non-interactive shell — continuing by default."
    fi
    case "$reply" in
        [yY]|[yY][eE][sS]) info "Continuing without those packages." ;;
        *) info "Stopping. Install the packages above and re-run this script."; exit 0 ;;
    esac
fi

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

# ---- 5. place the config --------------------------------------------------
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

# ---- 6. pre-install plugins (best effort) --------------------------------
info "Pre-installing plugins headlessly (lazy sync)…"
if ! nvim --headless "+Lazy! sync" +qa 2>/dev/null; then
    warn "Headless plugin sync skipped — it will run on first launch instead."
fi

# ---- 7. done --------------------------------------------------------------
info "Bootstrap complete."
cat <<'EOF'

Remaining first-run steps:
  1. nvim              # Mason installs LSPs / formatters / linters
                       #   watch progress with  :Mason
  2. :Copilot setup    # authenticate Copilot (first time only)

Verify anytime with  :checkhealth
EOF
