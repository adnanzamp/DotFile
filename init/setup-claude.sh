#!/usr/bin/env bash

# Claude Code settings setup — symlinks the repo's settings.json into
# ~/.claude/settings.json so Stop/Notification hooks (terminal bell) are
# picked up by the claude CLI.

setup_claude() {
    local dotfiles_dir="$1"
    local config_dir="$HOME/.claude"
    local target="$config_dir/settings.json"
    local source_conf="$dotfiles_dir/claude/settings.json"

    print_status "Setting up Claude Code settings..."

    if [ ! -f "$source_conf" ]; then
        print_warning "Source settings file missing: $source_conf"
        return 1
    fi

    mkdir -p "$config_dir"

    if [ -L "$target" ]; then
        local current_link
        current_link=$(readlink "$target")
        if [ "$current_link" = "$source_conf" ]; then
            print_success "Claude settings already linked"
            return 0
        else
            print_status "Replacing existing symlink at $target"
            rm "$target"
        fi
    elif [ -e "$target" ]; then
        local backup="$target.backup.$(date +%Y%m%d-%H%M%S)"
        print_status "Backing up existing $target -> $backup"
        mv "$target" "$backup"
    fi

    ln -s "$source_conf" "$target"
    print_success "Linked $target -> $source_conf"
    return 0
}
