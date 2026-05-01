#!/bin/bash

# Pulls the latest dotfiles and applies updates in-place:
#   - git pull (auto-stashes local changes)
#   - syncs neovim plugins via lazy.nvim
#   - reloads tmux config in any running tmux sessions
#
# Run from anywhere; the script resolves its own location.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status()  { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR" || { print_error "cannot cd to $DOTFILES_DIR"; exit 1; }

echo
print_status "Updating dotfiles in $DOTFILES_DIR"
echo "================================================"

# 1. git pull, stashing any local changes
STASHED=0
if ! git diff --quiet || ! git diff --cached --quiet; then
    print_warning "Local changes detected — stashing before pull"
    git stash push -u -m "update.sh auto-stash $(date +%s)" >/dev/null
    STASHED=1
fi

print_status "Pulling latest from origin..."
if git pull --ff-only origin "$(git branch --show-current)"; then
    print_success "Repo updated"
else
    print_error "git pull failed — resolve manually and re-run"
    [ "$STASHED" -eq 1 ] && git stash pop >/dev/null
    exit 1
fi

if [ "$STASHED" -eq 1 ]; then
    print_status "Restoring stashed local changes..."
    if git stash pop >/dev/null 2>&1; then
        print_success "Stash restored"
    else
        print_warning "Stash pop had conflicts — run 'git status' in $DOTFILES_DIR"
    fi
fi

# 2. Sync nvim plugins headlessly
if command_exists nvim; then
    print_status "Syncing neovim plugins (lazy.nvim)..."
    if nvim --headless "+Lazy! sync" +qall 2>&1 | tail -5; then
        print_success "Neovim plugins synced"
    else
        print_warning "Lazy sync exited non-zero (often benign — open nvim and check :Lazy)"
    fi
else
    print_warning "nvim not on PATH — skipping plugin sync"
fi

# 3. Reload tmux config in every live session
if command_exists tmux && tmux list-sessions >/dev/null 2>&1; then
    print_status "Reloading tmux config in running sessions..."
    tmux source-file ~/.config/tmux/tmux.conf 2>/dev/null
    print_success "Tmux config reloaded — install new tpm plugins with <prefix> I"
else
    print_status "No tmux sessions running — config will load fresh next time"
fi

echo
print_success "Update complete"
echo "Next steps:"
echo "  - Restart nvim sessions to pick up new keymaps/options"
echo "  - In tmux: <prefix> I to install any new tpm plugins"
