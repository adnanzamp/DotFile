#!/usr/bin/env bash

# bin/ setup — symlinks standalone executables from this repo's bin/ directory
# into ~/.local/bin so they are runnable as commands after dotfiles init.
# The generated .zshrc adds ~/.local/bin to PATH when the directory exists, so
# we just need to create it and drop the symlinks in.

setup_bin() {
    local dotfiles_dir="$1"
    local src_dir="$dotfiles_dir/bin"
    local target_dir="$HOME/.local/bin"

    print_status "Setting up user bin scripts..."

    if [ ! -d "$src_dir" ]; then
        print_warning "No bin/ directory in dotfiles ($src_dir); skipping"
        return 0
    fi

    mkdir -p "$target_dir"

    local script name target current_link backup linked=0
    for script in "$src_dir"/*; do
        [ -f "$script" ] || continue          # skip if dir is empty / non-files
        chmod +x "$script" 2>/dev/null
        name="$(basename "$script")"
        target="$target_dir/$name"

        if [ -L "$target" ]; then
            current_link=$(readlink "$target")
            if [ "$current_link" = "$script" ]; then
                print_success "$name already linked"
                linked=$((linked + 1))
                continue
            fi
            print_status "Replacing existing symlink at $target"
            rm -f "$target"
        elif [ -e "$target" ]; then
            backup="$target.backup.$(date +%Y%m%d-%H%M%S)"
            print_status "Backing up existing $target -> $backup"
            mv "$target" "$backup"
        fi

        ln -s "$script" "$target"
        print_success "Linked $target -> $script"
        linked=$((linked + 1))
    done

    print_status "Installed $linked script(s) into $target_dir"
    return 0
}
