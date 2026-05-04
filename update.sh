#!/bin/bash

# Pulls the latest dotfiles and brings every tracked component in sync:
#   - git pull (auto-stashes local changes)
#   - regenerates ~/.zshrc from the embedded template (force, since the
#     setup-zsh.sh signature check otherwise skips)
#   - re-applies tmux symlink + Claude settings symlink
#   - re-copies the custom oh-my-posh theme into ~/.poshthemes/
#   - git pulls each zsh plugin (autosuggestions, syntax-highlighting, completions)
#   - updates tmux TPM plugins
#   - syncs neovim plugins via lazy.nvim
#   - reloads tmux config in any running tmux sessions
#
# Heavy installs (apt packages, oh-my-posh binary, nerd fonts, cursor
# extensions) are NOT re-run here — for a full rebuild use bootstrap.sh.
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

# ---------------------------------------------------------------------------
# 1. git pull, stashing any local changes
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# 2. Regenerate ~/.zshrc from the embedded template (force)
#    setup-zsh.sh skips when its signature check passes, so we move the
#    existing file aside to make it definitely re-create it. setup_zsh also
#    handles oh-my-posh theme copy + (idempotent) plugin install.
# ---------------------------------------------------------------------------
if [ -f "$DOTFILES_DIR/init/setup-zsh.sh" ]; then
    print_status "Regenerating ~/.zshrc and re-running zsh setup..."
    if [ -f "$HOME/.zshrc" ]; then
        mv "$HOME/.zshrc" "$HOME/.zshrc.update-bak.$(date +%Y%m%d-%H%M%S)"
    fi
    # shellcheck disable=SC1090
    source "$DOTFILES_DIR/init/setup-zsh.sh"
    setup_zsh "" >/dev/null 2>&1 && print_success "zsh config regenerated" \
        || print_warning "setup_zsh exited non-zero — inspect manually"
fi

# ---------------------------------------------------------------------------
# 3. Re-apply tmux setup (symlink + TPM clone are idempotent)
# ---------------------------------------------------------------------------
if [ -f "$DOTFILES_DIR/init/setup-tmux.sh" ]; then
    # shellcheck disable=SC1090
    source "$DOTFILES_DIR/init/setup-tmux.sh"
    setup_tmux "$DOTFILES_DIR" >/dev/null 2>&1 && print_success "tmux config in sync" \
        || print_warning "setup_tmux exited non-zero"
fi

# ---------------------------------------------------------------------------
# 4. Re-apply Claude Code settings symlink
# ---------------------------------------------------------------------------
if [ -f "$DOTFILES_DIR/init/setup-claude.sh" ]; then
    # shellcheck disable=SC1090
    source "$DOTFILES_DIR/init/setup-claude.sh"
    setup_claude "$DOTFILES_DIR" >/dev/null 2>&1 && print_success "Claude settings linked" \
        || print_warning "setup_claude exited non-zero"
fi

# ---------------------------------------------------------------------------
# 5. Update zsh custom plugins (git pull each)
# ---------------------------------------------------------------------------
ZSH_PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"
if [ -d "$ZSH_PLUGINS_DIR" ]; then
    for plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-completions; do
        plugin_dir="$ZSH_PLUGINS_DIR/$plugin"
        if [ -d "$plugin_dir/.git" ]; then
            print_status "Updating $plugin..."
            if git -C "$plugin_dir" pull --ff-only --quiet; then
                print_success "$plugin updated"
            else
                print_warning "$plugin pull failed (skipping)"
            fi
        fi
    done
else
    print_warning "Oh My Zsh custom plugins dir missing — run bootstrap.sh"
fi

# ---------------------------------------------------------------------------
# 6. Update tmux TPM plugins
# ---------------------------------------------------------------------------
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [ -x "$TPM_DIR/bin/update_plugins" ]; then
    print_status "Updating tmux plugins via TPM..."
    if "$TPM_DIR/bin/update_plugins" all >/dev/null 2>&1; then
        print_success "tmux plugins updated"
    else
        print_warning "TPM update_plugins exited non-zero"
    fi
fi

# ---------------------------------------------------------------------------
# 7. Sync nvim plugins headlessly
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# 8. Reload tmux config in every live session
# ---------------------------------------------------------------------------
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
echo "  - Open a fresh shell or run: exec zsh"
echo "  - Restart nvim sessions to pick up new keymaps/options"
echo "  - In tmux: <prefix> I to install any new tpm plugins"
