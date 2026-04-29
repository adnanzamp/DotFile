#!/usr/bin/env bash

# tmux setup — installs tmux, links the repo's tmux.conf into
# ~/.config/tmux/tmux.conf, clones TPM, and pre-installs the configured plugins.

setup_tmux() {
    local dotfiles_dir="$1"
    local config_dir="$HOME/.config/tmux"
    local target="$config_dir/tmux.conf"
    local source_conf="$dotfiles_dir/tmux/tmux.conf"

    print_status "Setting up tmux..."

    if ! command_exists tmux; then
        install_tmux || return 1
    else
        print_success "tmux is already installed ($(tmux -V))"
    fi

    mkdir -p "$config_dir/plugins"

    if [ -L "$target" ]; then
        local current_link
        current_link=$(readlink "$target")
        if [ "$current_link" = "$source_conf" ]; then
            print_success "tmux config already linked"
        else
            print_status "Replacing existing symlink at $target"
            rm "$target"
            ln -s "$source_conf" "$target"
            print_success "Linked $target -> $source_conf"
        fi
    elif [ -e "$target" ]; then
        local backup="$target.backup.$(date +%Y%m%d-%H%M%S)"
        print_status "Backing up existing $target -> $backup"
        mv "$target" "$backup"
        ln -s "$source_conf" "$target"
        print_success "Linked $target -> $source_conf"
    else
        ln -s "$source_conf" "$target"
        print_success "Linked $target -> $source_conf"
    fi

    install_tmux_plugins "$config_dir"
    return 0
}

install_tmux() {
    print_status "Installing tmux..."
    local os
    os=$(uname -s)

    if [ "$os" = "Darwin" ]; then
        if command_exists brew; then
            brew install tmux || return 1
        else
            print_warning "Homebrew not found; install tmux manually on macOS"
            return 1
        fi
    elif [ "$os" = "Linux" ]; then
        if command_exists apt-get && command_exists sudo; then
            sudo apt-get update -qq && sudo apt-get install -y tmux || return 1
        elif command_exists dnf && command_exists sudo; then
            sudo dnf install -y tmux || return 1
        elif command_exists pacman && command_exists sudo; then
            sudo pacman -S --noconfirm tmux || return 1
        else
            print_warning "No supported package manager / sudo for installing tmux"
            return 1
        fi
    else
        print_warning "Unsupported OS for tmux install: $os"
        return 1
    fi

    if command_exists tmux; then
        print_success "tmux installed: $(tmux -V)"
        return 0
    fi
    return 1
}

install_tmux_plugins() {
    local config_dir="$1"
    local plugins_dir="$config_dir/plugins"

    # TPM
    if [ ! -d "$plugins_dir/tpm" ]; then
        print_status "Cloning TPM..."
        git clone --depth 1 https://github.com/tmux-plugins/tpm "$plugins_dir/tpm" >/dev/null 2>&1 \
            && print_success "TPM cloned" \
            || { print_warning "Failed to clone TPM"; return 1; }
    else
        print_success "TPM already present"
    fi

    # Plugins listed in tmux.conf — clone directly so first tmux launch works
    # without needing to press prefix + I.
    local repos=(
        "tmux-plugins/tmux-sensible"
        "christoomey/vim-tmux-navigator"
        "adnanhashmi09/catppuccin-tmux"
        "tmux-plugins/tmux-yank"
    )

    for repo in "${repos[@]}"; do
        local name="${repo##*/}"
        if [ ! -d "$plugins_dir/$name" ]; then
            print_status "Cloning $repo..."
            git clone --depth 1 "https://github.com/$repo" "$plugins_dir/$name" >/dev/null 2>&1 \
                && print_success "$name cloned" \
                || print_warning "Failed to clone $repo"
        fi
    done
}
