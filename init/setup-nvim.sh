#!/usr/bin/env bash

# Neovim setup — installs the latest stable Neovim and links the NvChad-based
# config from this repo into ~/.config/nvim.

setup_nvim() {
    local dotfiles_dir="$1"
    local target="$HOME/.config/nvim"

    print_status "Setting up Neovim..."

    # Install / upgrade Neovim
    if ! command_exists nvim; then
        install_neovim || return 1
    else
        local installed_version
        installed_version=$(nvim --version | head -1 | awk '{print $2}')
        print_success "Neovim is already installed ($installed_version)"
    fi

    # Symlink (or copy) the repo's nvim config into ~/.config/nvim
    mkdir -p "$HOME/.config"

    if [ -L "$target" ]; then
        local current_link
        current_link=$(readlink "$target")
        if [ "$current_link" = "$dotfiles_dir/nvim" ]; then
            print_success "Neovim config already linked"
            return 0
        fi
        print_status "Replacing existing symlink at $target"
        rm "$target"
    elif [ -e "$target" ]; then
        local backup="$target.backup.$(date +%Y%m%d-%H%M%S)"
        print_status "Backing up existing $target -> $backup"
        mv "$target" "$backup"
    fi

    ln -s "$dotfiles_dir/nvim" "$target"
    print_success "Linked $target -> $dotfiles_dir/nvim"

    print_status "First launch will trigger lazy.nvim to install plugins."
    return 0
}

install_neovim() {
    print_status "Installing latest Neovim..."

    local arch
    arch=$(uname -m)
    local os
    os=$(uname -s)

    if [ "$os" = "Darwin" ]; then
        if command_exists brew; then
            brew install neovim || return 1
        else
            print_warning "Homebrew not found; install nvim manually on macOS"
            return 1
        fi
    elif [ "$os" = "Linux" ]; then
        local asset
        case "$arch" in
            x86_64) asset="nvim-linux-x86_64.tar.gz" ;;
            aarch64|arm64) asset="nvim-linux-arm64.tar.gz" ;;
            *)
                print_warning "Unsupported architecture for Neovim binary release: $arch"
                return 1
                ;;
        esac

        local tmpfile="/tmp/$asset"
        if ! curl -sLo "$tmpfile" "https://github.com/neovim/neovim/releases/latest/download/$asset"; then
            print_warning "Failed to download Neovim"
            return 1
        fi

        local install_dir="/opt/${asset%.tar.gz}"
        if command_exists sudo; then
            sudo rm -rf "$install_dir" \
                && sudo tar -C /opt -xzf "$tmpfile" \
                && sudo ln -sf "$install_dir/bin/nvim" /usr/local/bin/nvim
        else
            print_warning "sudo not available; cannot install Neovim system-wide"
            rm -f "$tmpfile"
            return 1
        fi
        rm -f "$tmpfile"
    else
        print_warning "Unsupported OS: $os"
        return 1
    fi

    if command_exists nvim; then
        print_success "Neovim installed: $(nvim --version | head -1)"
        return 0
    fi
    print_warning "Neovim install reported success but binary not on PATH"
    return 1
}
