#!/bin/bash

# Zsh Setup Script
# Part of the general dotfile collection
# Handles complete zsh setup: aliases, plugins, and basic configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install zsh if needed
install_zsh() {
    print_status "Ensuring zsh is installed..."
    
    # Debug: Check multiple ways zsh might be available
    local zsh_path=""
    if command_exists zsh; then
        zsh_path=$(which zsh)
        print_status "Found zsh at: $zsh_path"
    elif [ -f "/usr/bin/zsh" ]; then
        zsh_path="/usr/bin/zsh"
        print_status "Found zsh at: $zsh_path"
    elif [ -f "/bin/zsh" ]; then
        zsh_path="/bin/zsh"
        print_status "Found zsh at: $zsh_path"
    fi
    
    if [ -n "$zsh_path" ]; then
        print_success "Zsh is already installed at: $zsh_path"
        return 0
    fi
    
    print_warning "Zsh is not installed. Installing zsh..."
    
    if command_exists apt-get; then
        # Ubuntu/Debian
        print_status "Installing zsh via apt-get..."
        sudo apt-get update
        sudo apt-get install -y zsh
    elif command_exists yum; then
        # CentOS/RHEL
        print_status "Installing zsh via yum..."
        sudo yum install -y zsh
    elif command_exists brew; then
        # macOS
        print_status "Installing zsh via Homebrew..."
        brew install zsh
    else
        print_error "No supported package manager found. Please install zsh manually."
        return 1
    fi
    
    # Check again after installation
    if command_exists zsh; then
        print_success "Zsh installed successfully at: $(which zsh)"
    else
        print_error "Failed to install zsh"
        return 1
    fi
}

# Function to set zsh as default shell
set_zsh_default() {
    print_status "Setting zsh as default shell..."
    
    # Find zsh path
    local zsh_path=""
    if command_exists zsh; then
        zsh_path=$(which zsh)
    elif [ -f "/usr/bin/zsh" ]; then
        zsh_path="/usr/bin/zsh"
    elif [ -f "/bin/zsh" ]; then
        zsh_path="/bin/zsh"
    fi
    
    if [ -z "$zsh_path" ]; then
        print_error "Cannot find zsh installation"
        return 1
    fi
    
    print_status "Zsh path: $zsh_path"
    
    # Get current user - handle container environments
    local current_user="${USER:-$(whoami)}"
    if [ -z "$current_user" ]; then
        print_warning "Could not determine current user, skipping default shell change"
        return 0
    fi
    
    # Get current default shell
    local current_shell=""
    if command_exists dscl; then
        # macOS
        current_shell=$(dscl . -read /Users/$current_user UserShell 2>/dev/null | awk '{print $2}')
    else
        # Linux - use grep to be more reliable in containers
        current_shell=$(grep "^${current_user}:" /etc/passwd 2>/dev/null | cut -d: -f7)
    fi
    
    print_status "Current default shell: ${current_shell:-unknown}"
    
    if [ -n "$current_shell" ] && [ "$current_shell" != "$zsh_path" ]; then
        print_warning "Current default shell is not zsh: $current_shell"
        print_status "Setting zsh as default shell..."
        
        # Try chsh, but don't fail if it doesn't work (common in containers)
        if sudo chsh -s "$zsh_path" "$current_user" 2>/dev/null; then
            print_success "Zsh set as default shell: $zsh_path"
        else
            print_warning "Could not change default shell (common in containers), you can run zsh manually"
        fi
    elif [ -z "$current_shell" ]; then
        print_warning "Could not determine current shell, attempting to set zsh..."
        sudo chsh -s "$zsh_path" "$current_user" 2>/dev/null || print_warning "Could not change default shell"
    else
        print_success "Zsh is already the default shell"
    fi
}

# Function to install Oh My Zsh and plugins
install_oh_my_zsh() {
    local home_dir="$1"
    
    print_status "Installing Oh My Zsh and plugins..."
    
    local omz_installed=0
    local omz_skipped=0
    
    # Install Oh My Zsh
    if [ ! -d "$home_dir/.oh-my-zsh" ]; then
        print_status "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed"
        ((omz_installed++))
    else
        print_success "Oh My Zsh already installed"
        ((omz_skipped++))
    fi
    
    # Install essential plugins
    local plugins=(
        "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions.git"
        "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting.git"
        "zsh-completions:https://github.com/zsh-users/zsh-completions.git"
    )
    
    # Ensure custom plugins directory exists
    local custom_plugins_dir="$home_dir/.oh-my-zsh/custom/plugins"
    mkdir -p "$custom_plugins_dir"
    
    for plugin in "${plugins[@]}"; do
        local plugin_name=$(echo "$plugin" | sed 's/:.*//')
        local plugin_url=$(echo "$plugin" | sed 's/^[^:]*://')
        
        # Different paths for different plugins
        local plugin_dir=""
        case "$plugin_name" in
            "zsh-autosuggestions")
                plugin_dir="$home_dir/.oh-my-zsh/custom/plugins/$plugin_name"
                ;;
            "zsh-syntax-highlighting")
                plugin_dir="$home_dir/.oh-my-zsh/custom/plugins/$plugin_name"
                ;;
            "zsh-completions")
                plugin_dir="$home_dir/.oh-my-zsh/custom/plugins/$plugin_name"
                ;;
        esac
        
        if [ ! -d "$plugin_dir" ]; then
            print_status "Installing $plugin_name..."
            print_status "Cloning from: $plugin_url"
            print_status "Installing to: $plugin_dir"
            if git clone "$plugin_url" "$plugin_dir"; then
                print_success "$plugin_name installed"
                ((omz_installed++))
            else
                print_warning "Failed to install $plugin_name, continuing..."
                print_status "Checking if directory was created anyway..."
                if [ -d "$plugin_dir" ]; then
                    print_success "$plugin_name directory exists, plugin may be available"
                    ((omz_installed++))
                else
                    print_warning "$plugin_name directory not found"
                fi
            fi
        else
            print_success "$plugin_name already installed"
            ((omz_skipped++))
        fi
    done
    
    # Return Oh My Zsh installation status
    if [ $omz_installed -gt 0 ]; then
        echo "omz_installed:$omz_installed"
    fi
    if [ $omz_skipped -gt 0 ]; then
        echo "omz_skipped:$omz_skipped"
    fi
}

# Function to create comprehensive .zshrc
create_zshrc() {
    local home_dir="$1"
    local dotfiles_dir="$2"
    local zshrc_file="$home_dir/.zshrc"
    
    print_status "Checking .zshrc configuration..."
    
    # Check if .zshrc already exists and has our configuration
    if [ -f "$zshrc_file" ]; then
        # Only check for our signature, don't try to source it in bash
        if grep -q "Generated by dotfiles setup script" "$zshrc_file" && \
           grep -q "zsh-autosuggestions" "$zshrc_file" && \
           grep -q "zsh-syntax-highlighting" "$zshrc_file" && \
           grep -q "oh-my-posh" "$zshrc_file" && \
           grep -q "source.*\.aliases" "$zshrc_file"; then
            print_success ".zshrc already configured correctly"
            return 0
        else
            # Only backup if the file exists but doesn't have our configuration
            if [ -s "$zshrc_file" ]; then
                print_status "Backing up existing .zshrc..."
                cp "$zshrc_file" "$zshrc_file.backup.$(date +%Y%m%d-%H%M%S)"
                print_status "Backup created: $zshrc_file.backup.$(date +%Y%m%d-%H%M%S)"
            fi
        fi
    fi
    
    print_status "Creating comprehensive .zshrc..."
    
    # Backup existing .zshrc
    if [ -f "$zshrc_file" ]; then
        cp "$zshrc_file" "$zshrc_file.backup.$(date +%Y%m%d-%H%M%S)"
        print_status "Backup created: $zshrc_file.backup.$(date +%Y%m%d-%H%M%S)"
    fi
    
    # Create comprehensive .zshrc
    cat > "$zshrc_file" << 'EOF'
# =============================================================================
# Zsh Configuration
# Generated by dotfiles setup script
# =============================================================================

# =============================================================================
# Oh My Zsh Configuration
# =============================================================================

export ZSH="$HOME/.oh-my-zsh"

# No theme - we use oh-my-posh instead
ZSH_THEME=""

# Essential plugins for productivity
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# =============================================================================
# Oh My Posh Configuration
# =============================================================================

# Initialize oh-my-posh with a theme
if command -v oh-my-posh &> /dev/null; then
    # Use agnoster theme by default (can be changed to any theme in ~/.poshthemes/)
    if [ -f "$HOME/.poshthemes/agnoster.omp.json" ]; then
        eval "$(oh-my-posh init zsh --config $HOME/.poshthemes/agnoster.omp.json)"
    elif [ -f "$HOME/.poshthemes/jandedobbeleer.omp.json" ]; then
        eval "$(oh-my-posh init zsh --config $HOME/.poshthemes/jandedobbeleer.omp.json)"
    else
        eval "$(oh-my-posh init zsh)"
    fi
fi

# =============================================================================
# Environment Variables
# =============================================================================

# Add custom paths if they exist
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
fi

# Add go bin path if it exists
if [ -d "$HOME/go/bin" ]; then
    export PATH="$HOME/go/bin:$PATH"
fi

# =============================================================================
# History Configuration
# =============================================================================

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# =============================================================================
# Completions
# =============================================================================

autoload -U compinit && compinit

# =============================================================================
# Source Dotfiles Aliases
# =============================================================================

EOF

    # Add the dotfiles aliases source line
    echo "# Source dotfiles aliases" >> "$zshrc_file"
    echo "source \"$dotfiles_dir/.aliases\"" >> "$zshrc_file"
    
    # Add final section
    cat >> "$zshrc_file" << 'EOF'

# =============================================================================
# Tool Configurations
# =============================================================================

# Lazygit configuration
# export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml"

# =============================================================================
# Basic Prompt (fallback if oh-my-posh not available)
# =============================================================================

if ! command -v oh-my-posh &> /dev/null && [ -z "$ZSH_THEME" ]; then
    PROMPT='%n@%m %~ %# '
fi

# =============================================================================
# Extensible Configuration Area
# =============================================================================

# Add your custom configurations below this line
# This area is preserved during updates

EOF

    print_success "Comprehensive .zshrc created at $zshrc_file"
}

# Function to install essential packages
install_packages() {
    print_status "Installing essential packages..."
    
    # Core packages + network tools
    local packages=(
        "curl" "wget" "tree" "htop" "jq"
        # Network tools
        "net-tools" "dnsutils" "iputils-ping" "traceroute" "nmap" 
        "netcat-openbsd" "tcpdump" "iftop" "mtr" "whois" "nload"
    )
    local installed_count=0
    local skipped_count=0
    
    if command_exists apt-get; then
        # Ubuntu/Debian - update package list first
        print_status "Updating package list..."
        sudo apt-get update -qq
        
        for package in "${packages[@]}"; do
            if dpkg -l | grep -q "^ii  $package "; then
                print_success "$package already installed"
                ((skipped_count++))
            else
                print_status "Installing $package..."
                if sudo apt-get install -y "$package" 2>/dev/null; then
                    ((installed_count++))
                else
                    print_warning "Could not install $package, continuing..."
                fi
            fi
        done
    elif command_exists yum; then
        # CentOS/RHEL
        local yum_packages=("curl" "wget" "tree" "htop" "jq" "net-tools" "bind-utils" "iputils" "traceroute" "nmap" "nmap-ncat" "tcpdump" "iftop" "mtr" "whois")
        for package in "${yum_packages[@]}"; do
            if rpm -q "$package" >/dev/null 2>&1; then
                print_success "$package already installed"
                ((skipped_count++))
            else
                print_status "Installing $package..."
                if sudo yum install -y "$package" 2>/dev/null; then
                    ((installed_count++))
                else
                    print_warning "Could not install $package, continuing..."
                fi
            fi
        done
    elif command_exists brew; then
        # macOS
        local brew_packages=("curl" "wget" "tree" "htop" "jq" "nmap" "mtr" "whois" "iftop")
        for package in "${brew_packages[@]}"; do
            if brew list "$package" >/dev/null 2>&1; then
                print_success "$package already installed"
                ((skipped_count++))
            else
                print_status "Installing $package..."
                if brew install "$package" 2>/dev/null; then
                    ((installed_count++))
                else
                    print_warning "Could not install $package, continuing..."
                fi
            fi
        done
    else
        print_warning "No supported package manager found, skipping package installation"
    fi
    
    # Return package installation status
    if [ $installed_count -gt 0 ]; then
        echo "packages_installed:$installed_count"
    fi
    if [ $skipped_count -gt 0 ]; then
        echo "packages_skipped:$skipped_count"
    fi
}

# Function to install lazygit
install_lazygit() {
    print_status "Installing lazygit..."
    
    if command_exists lazygit; then
        print_success "lazygit is already installed"
        return 0
    fi
    
    if command_exists apt-get; then
        # Ubuntu/Debian - install from GitHub releases
        print_status "Installing lazygit from GitHub releases..."
        local LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        if [ -z "$LAZYGIT_VERSION" ]; then
            LAZYGIT_VERSION="0.44.1"
        fi
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm -f lazygit lazygit.tar.gz
        print_success "lazygit installed successfully"
    elif command_exists brew; then
        # macOS
        print_status "Installing lazygit via Homebrew..."
        brew install lazygit
        print_success "lazygit installed successfully"
    elif command_exists yum; then
        # CentOS/RHEL - install from GitHub releases
        print_status "Installing lazygit from GitHub releases..."
        local LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        if [ -z "$LAZYGIT_VERSION" ]; then
            LAZYGIT_VERSION="0.44.1"
        fi
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm -f lazygit lazygit.tar.gz
        print_success "lazygit installed successfully"
    else
        print_warning "Could not install lazygit - no supported package manager found"
        return 1
    fi
}

# Function to install oh-my-posh
install_oh_my_posh() {
    print_status "Installing oh-my-posh..."
    
    if command_exists oh-my-posh; then
        print_success "oh-my-posh is already installed"
        return 0
    fi
    
    # Install oh-my-posh
    print_status "Downloading oh-my-posh..."
    if curl -s https://ohmyposh.dev/install.sh | bash -s; then
        print_success "oh-my-posh installed successfully"
    else
        print_warning "Failed to install oh-my-posh via install script, trying alternative method..."
        # Alternative: install via Homebrew if available
        if command_exists brew; then
            brew install jandedobbeleer/oh-my-posh/oh-my-posh
            print_success "oh-my-posh installed via Homebrew"
        else
            # Manual download for Linux
            sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
            sudo chmod +x /usr/local/bin/oh-my-posh
            print_success "oh-my-posh installed manually"
        fi
    fi
    
    # Download themes
    local themes_dir="$HOME/.poshthemes"
    if [ ! -d "$themes_dir" ]; then
        print_status "Downloading oh-my-posh themes..."
        mkdir -p "$themes_dir"
        wget -q https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O "$themes_dir/themes.zip"
        unzip -q "$themes_dir/themes.zip" -d "$themes_dir"
        chmod u+rw "$themes_dir"/*.json
        rm -f "$themes_dir/themes.zip"
        print_success "oh-my-posh themes downloaded"
    else
        print_success "oh-my-posh themes already exist"
    fi
}

# Function to install nvm (Node Version Manager)
install_nvm() {
    print_status "Checking nvm..."
    
    # Check if nvm is already installed
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        print_success "nvm is already installed"
        # shellcheck source=/dev/null
        . "$NVM_DIR/nvm.sh"
        print_status "nvm version: $(nvm --version)"
        return 0
    fi
    
    print_status "Installing nvm..."
    
    # Install nvm using the official install script
    if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash; then
        print_success "nvm installed successfully"
        
        # Load nvm into current shell
        export NVM_DIR="$HOME/.nvm"
        # shellcheck source=/dev/null
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        # shellcheck source=/dev/null
        [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
        
        print_status "nvm version: $(nvm --version)"
        return 0
    else
        print_warning "Failed to install nvm"
        print_status "You can install manually from: https://github.com/nvm-sh/nvm"
        return 1
    fi
}

# Function to install Node.js and npm via nvm (version 22+)
install_nodejs() {
    print_status "Checking Node.js and npm..."
    
    # Load nvm if available
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        # shellcheck source=/dev/null
        . "$NVM_DIR/nvm.sh"
    fi
    
    # Check if Node.js 22+ is already installed and active
    if command_exists node && command_exists npm; then
        local node_version=$(node --version | sed 's/v//' | cut -d. -f1)
        if [ "$node_version" -ge 22 ] 2>/dev/null; then
            print_success "Node.js and npm are already installed (v22+)"
            print_status "Node.js version: $(node --version)"
            print_status "npm version: $(npm --version)"
            return 0
        else
            print_status "Node.js version $(node --version) is below v22, upgrading..."
        fi
    fi
    
    # Install nvm if not available
    if ! command -v nvm >/dev/null 2>&1; then
        if ! install_nvm; then
            print_warning "Could not install nvm. Cannot proceed with Node.js installation."
            return 1
        fi
    fi
    
    print_status "Installing Node.js 22 via nvm..."
    
    # Install Node.js 22 (required by clawdbot)
    if nvm install 22; then
        print_success "Node.js 22 installed successfully"
        
        # Set Node.js 22 as the default version
        nvm alias default 22
        nvm use default
        print_success "Node.js 22 set as default version"
    else
        print_warning "Failed to install Node.js 22 via nvm"
        return 1
    fi
    
    # Verify installation
    if command_exists node && command_exists npm; then
        print_status "Node.js version: $(node --version)"
        print_status "npm version: $(npm --version)"
        return 0
    else
        print_warning "Node.js installation may have failed"
        return 1
    fi
}

# Function to install clawdbot (Claude Code CLI)
install_clawdbot() {
    print_status "Installing clawdbot..."
    
    # Load nvm if available
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        # shellcheck source=/dev/null
        . "$NVM_DIR/nvm.sh"
    fi
    
    # Check if clawdbot is already installed
    if command_exists clawdbot; then
        print_success "clawdbot is already installed"
        clawdbot --version 2>/dev/null || true
        return 0
    fi
    
    # Ensure npm is available, install Node.js if needed
    if ! command_exists npm; then
        print_status "npm is not installed. Installing Node.js first..."
        if ! install_nodejs; then
            print_warning "Failed to install Node.js. Cannot install clawdbot."
            return 1
        fi
    fi
    
    # Install clawdbot globally via npm
    print_status "Installing clawdbot via npm..."
    
    if npm i -g clawdbot; then
        print_success "clawdbot installed successfully"
        
        # Verify installation
        if command_exists clawdbot; then
            print_status "clawdbot version:"
            clawdbot --version 2>/dev/null || true
        fi
        return 0
    else
        print_warning "Failed to install clawdbot"
        print_status "You can install manually with:"
        print_status "  npm i -g clawdbot"
        return 1
    fi
}

# Function to install cursor CLI
install_cursor_cli() {
    print_status "Checking cursor CLI (agent)..."
    
    # Check for both 'cursor' and 'agent' commands
    if command_exists agent; then
        print_success "Cursor CLI (agent) is already installed"
        agent --version 2>/dev/null || true
        return 0
    fi
    
    if command_exists cursor; then
        print_success "cursor CLI is already installed"
        return 0
    fi
    
    print_status "Installing Cursor CLI..."
    
    # Install using official method from https://cursor.com/docs/cli/installation
    if curl https://cursor.com/install -fsS | bash; then
        print_success "Cursor CLI installed successfully"
        
        # Verify installation
        if command_exists agent; then
            print_status "Cursor CLI version:"
            agent --version 2>/dev/null || true
        fi
        return 0
    else
        print_warning "Failed to install Cursor CLI automatically"
        print_status "You can install manually with:"
        print_status "  curl https://cursor.com/install -fsS | bash"
        print_status ""
        print_status "After installation, verify with:"
        print_status "  agent --version"
        return 1
    fi
}

# Function to clone integrations-hub repository
clone_integrations_hub() {
    local repo_url="git@github.com:Zampfi/integrations-hub.git"
    
    # Determine the target directory for integrations-hub
    # Priority: 1) ~/zamp/services  2) parent of dotfiles dir  3) ~/services
    local target_dir=""
    
    if [ -d "$HOME/zamp/services" ]; then
        target_dir="$HOME/zamp/services/integrations-hub"
    elif [ -d "$HOME/services" ]; then
        target_dir="$HOME/services/integrations-hub"
    else
        # Create ~/zamp/services as default location
        target_dir="$HOME/zamp/services/integrations-hub"
    fi
    
    print_status "Checking integrations-hub repository..."
    print_status "Target directory: $target_dir"
    
    if [ -d "$target_dir" ]; then
        print_success "integrations-hub already exists at $target_dir"
        return 0
    fi
    
    # Ensure parent directory exists
    local parent_dir=$(dirname "$target_dir")
    if [ ! -d "$parent_dir" ]; then
        print_status "Creating directory at $parent_dir..."
        mkdir -p "$parent_dir"
    fi
    
    print_status "Cloning integrations-hub repository..."
    if git clone "$repo_url" "$target_dir"; then
        print_success "integrations-hub cloned successfully to $target_dir"
    else
        print_warning "Failed to clone integrations-hub. Please ensure SSH keys are configured for GitHub."
        print_status "Manual clone command: git clone $repo_url $target_dir"
        return 1
    fi
}

# Function to cleanup old backup files
cleanup_backups() {
    local home_dir="$1"
    local backup_pattern="$home_dir/.zshrc.backup.*"
    
    # Keep only the 3 most recent backups
    local backup_count=$(ls -1 $backup_pattern 2>/dev/null | wc -l)
    if [ "$backup_count" -gt 3 ]; then
        print_status "Cleaning up old backup files..."
        ls -1t $backup_pattern | tail -n +4 | xargs rm -f
        print_success "Removed $(($backup_count - 3)) old backup files"
    fi
}

# Main setup function
setup_zsh() {
    local remote_connection="$1"
    
    echo -e "${BLUE}🔧 Setting up Zsh Configuration${NC}"
    echo "=================================="
    
    local home_dir="$HOME"
    local dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    local services_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    
    print_status "Home directory: $home_dir"
    print_status "Dotfiles directory: $dotfiles_dir"
    print_status "Services directory: $services_dir"
    
    # Track what was installed vs what was already there
    local installed_components=()
    local skipped_components=()
    
    # Install zsh if needed
    if ! command_exists zsh && [ ! -f "/usr/bin/zsh" ] && [ ! -f "/bin/zsh" ]; then
        install_zsh
        installed_components+=("zsh")
    else
        print_success "Zsh is already installed"
        skipped_components+=("zsh")
    fi
    
    # Set zsh as default shell if needed
    local zsh_path=""
    if command_exists zsh; then
        zsh_path=$(which zsh)
    elif [ -f "/usr/bin/zsh" ]; then
        zsh_path="/usr/bin/zsh"
    elif [ -f "/bin/zsh" ]; then
        zsh_path="/bin/zsh"
    fi
    
    local current_user="${USER:-$(whoami)}"
    local current_shell=""
    if command_exists dscl; then
        current_shell=$(dscl . -read /Users/$current_user UserShell 2>/dev/null | awk '{print $2}')
    else
        current_shell=$(grep "^${current_user}:" /etc/passwd 2>/dev/null | cut -d: -f7)
    fi
    
    if [ -z "$current_shell" ] || [ "$current_shell" != "$zsh_path" ]; then
        set_zsh_default
        installed_components+=("default shell (zsh)")
    else
        print_success "Zsh is already the default shell"
        skipped_components+=("default shell (zsh)")
    fi
    
    # Install packages (including network tools)
    local package_results=$(install_packages)
    local packages_installed=$(echo "$package_results" | grep "packages_installed:" | cut -d: -f2)
    local packages_skipped=$(echo "$package_results" | grep "packages_skipped:" | cut -d: -f2)
    
    if [ -n "$packages_installed" ] && [ "$packages_installed" -gt 0 ]; then
        installed_components+=("essential + network packages ($packages_installed new)")
    fi
    if [ -n "$packages_skipped" ] && [ "$packages_skipped" -gt 0 ]; then
        skipped_components+=("essential + network packages ($packages_skipped existing)")
    fi
    
    # Install lazygit
    if command_exists lazygit; then
        skipped_components+=("lazygit")
    else
        if install_lazygit; then
            installed_components+=("lazygit")
        fi
    fi
    
    # Install oh-my-posh
    if command_exists oh-my-posh; then
        skipped_components+=("oh-my-posh")
    else
        if install_oh_my_posh; then
            installed_components+=("oh-my-posh")
        fi
    fi
    
    # Install Oh My Zsh and plugins
    local omz_results=$(install_oh_my_zsh "$home_dir")
    local omz_installed=$(echo "$omz_results" | grep "omz_installed:" | cut -d: -f2)
    local omz_skipped=$(echo "$omz_results" | grep "omz_skipped:" | cut -d: -f2)
    
    if [ -n "$omz_installed" ] && [ "$omz_installed" -gt 0 ]; then
        installed_components+=("Oh My Zsh and plugins ($omz_installed new)")
    fi
    if [ -n "$omz_skipped" ] && [ "$omz_skipped" -gt 0 ]; then
        skipped_components+=("Oh My Zsh and plugins ($omz_skipped existing)")
    fi
    
    # Clone integrations-hub repository
    # Check common locations for existing repo
    if [ -d "$HOME/zamp/services/integrations-hub" ] || [ -d "$HOME/services/integrations-hub" ]; then
        skipped_components+=("integrations-hub repo")
    else
        if clone_integrations_hub; then
            installed_components+=("integrations-hub repo")
        fi
    fi
    
    # Install Node.js and npm
    if command_exists node && command_exists npm; then
        skipped_components+=("Node.js/npm")
    else
        if install_nodejs; then
            installed_components+=("Node.js/npm")
        fi
    fi
    
    # Install clawdbot (claude-code)
    if command_exists claude; then
        skipped_components+=("clawdbot (claude-code)")
    else
        if install_clawdbot; then
            installed_components+=("clawdbot (claude-code)")
        fi
    fi
    
    # Check and install cursor CLI
    if command_exists agent || command_exists cursor; then
        skipped_components+=("cursor CLI")
    else
        if install_cursor_cli; then
            installed_components+=("cursor CLI")
        fi
    fi
    
    # Create .zshrc
    if create_zshrc "$home_dir" "$dotfiles_dir"; then
        installed_components+=("zshrc configuration")
    else
        skipped_components+=("zshrc configuration")
    fi
    
    # Cleanup old backup files
    cleanup_backups "$home_dir"
    
    print_success "Zsh setup completed successfully!"
    echo ""
    
    if [ ${#installed_components[@]} -gt 0 ]; then
        print_status "✅ Installed/Updated:"
        for component in "${installed_components[@]}"; do
            print_status "  - $component"
        done
    fi
    
    if [ ${#skipped_components[@]} -gt 0 ]; then
        print_status "⏭️  Skipped (already exists):"
        for component in "${skipped_components[@]}"; do
            print_status "  - $component"
        done
    fi
    
    echo ""
    print_status "Your zsh configuration includes:"
    print_status "  ✅ All your aliases loaded (including GitHub git shortcuts: gk, gr, etc.)"
    print_status "  ✅ Oh My Zsh framework"
    print_status "  ✅ Oh My Posh (beautiful prompt themes)"
    print_status "  ✅ zsh-autosuggestions (fish-like suggestions)"
    print_status "  ✅ zsh-syntax-highlighting (command highlighting)"
    print_status "  ✅ zsh-completions (enhanced completions)"
    print_status "  ✅ Git plugin"
    print_status "  ✅ Essential packages (curl, wget, tree, htop, jq)"
    print_status "  ✅ Network tools (net-tools, nmap, tcpdump, mtr, etc.)"
    print_status "  ✅ Lazygit (terminal UI for git)"
    print_status "  ✅ Clawdbot (Claude Code CLI)"
    print_status "  ✅ Cursor CLI"
    print_status "  ✅ integrations-hub repository"
    print_status "  ✅ Extensible configuration area for future additions"
    echo ""
    print_status "Git shortcuts available:"
    print_status "  gk=checkout, gr=rebase, gm=merge, gb=branch, gf=fetch"
    print_status "  lg=lazygit, gpf=push --force-with-lease, gpr=pull --rebase"
    echo ""
    print_status "To apply the configuration:"
    print_status "  - Restart your terminal"
    print_status "  - Or run: source ~/.zshrc"
    echo ""
    print_status "You should now see:"
    print_status "  - Beautiful oh-my-posh prompt"
    print_status "  - Command suggestions as you type"
    print_status "  - Syntax highlighting (valid/invalid commands)"
    print_status "  - Enhanced tab completion"
    print_status "  - All your aliases working"
} 