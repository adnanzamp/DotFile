# General Dotfiles

A collection of dotfiles inspired by [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles), focused on developer productivity with zsh, aliases, and essential tools.

## Features

- **Zsh as Default Shell**: Automatically sets zsh as default with Oh My Zsh
- **Oh My Posh**: Beautiful, customizable prompt themes
- **Comprehensive Git Aliases**: GitHub-style shortcuts (gk, gr, gm, etc.)
- **Network Tools**: Full suite of networking utilities
- **Lazygit**: Terminal UI for git operations
- **zoxide**: Smarter `cd` (replaces the built-in `cd`)
- **Neovim**: Latest stable + NvChad-based config
- **tmux**: Config + TPM + plugins, prefix is `Ctrl+Space`
- **Cursor Extensions**: Automated installation of essential Cursor extensions
- **Auto Clone Repos**: Automatically clones integrations-hub repository
- **Modular Structure**: Easy to maintain and extend

## Installation

### Using the bootstrap script

Clone the repository and run the bootstrap script:

```bash
git clone <your-repo-url> && cd DotFile && source bootstrap.sh
```

### Manual installation

1. **Install aliases**: Add to your shell configuration file (`.bashrc`, `.zshrc`, etc.):
   ```bash
   source ~/path/to/dotfiles/.aliases
   ```

2. **Install Cursor extensions**: Run the extensions installer:
   ```bash
   source ~/path/to/dotfiles/init/cursor-extensions.sh
   ```

## Structure

```
DotFile/
├── bootstrap.sh              # Main bootstrap script
├── .aliases                  # Shell aliases
├── init/
│   ├── cursor-extensions.sh  # Cursor extensions installer
│   ├── setup-zsh.sh          # Zsh setup (oh-my-zsh, oh-my-posh, tools, zoxide)
│   ├── setup-nvim.sh         # Neovim install + symlink config
│   ├── setup-tmux.sh         # tmux install + symlink config + TPM plugins
│   └── reload-aliases.sh     # Reload aliases helper
├── nvim/                     # NvChad-based Neovim config (linked to ~/.config/nvim)
├── tmux/                     # tmux.conf (linked to ~/.config/tmux/tmux.conf)
└── README.md
```

## What Gets Installed

### Shell & Prompt
- **Zsh** - Set as default shell
- **Oh My Zsh** - Zsh framework with plugins
- **Oh My Posh** - Beautiful prompt themes
- **zsh-autosuggestions** - Fish-like suggestions
- **zsh-syntax-highlighting** - Command highlighting
- **zsh-completions** - Enhanced completions

### Development Tools
- **Lazygit** - Terminal UI for git (`lg` alias)
- **Cursor CLI** - Cursor command line tools
- **Claude Code** - Official Anthropic CLI (skipped if `claude` is already on PATH)
- **zoxide** - Smarter `cd`; the generated `.zshrc` initializes it with `--cmd cd`,
  so `cd <fragment>` jumps to the highest-frecency match
- **Neovim** - Latest binary + NvChad-based config under `nvim/` symlinked to `~/.config/nvim`
- **tmux** - Config under `tmux/tmux.conf` symlinked to `~/.config/tmux/tmux.conf`,
  TPM cloned to `~/.config/tmux/plugins/tpm`, and the configured plugins
  (tmux-sensible, vim-tmux-navigator, catppuccin-tmux, tmux-yank) pre-cloned

### Network Tools
- `net-tools` - Basic networking (ifconfig, netstat)
- `dnsutils` - DNS tools (dig, nslookup)
- `nmap` - Network scanner
- `tcpdump` - Packet analyzer
- `mtr` - Network diagnostics
- `traceroute` - Route tracing
- `iftop` - Bandwidth monitoring
- `whois` - Domain lookup

### Repositories
- **integrations-hub** - Cloned automatically to services directory

## Aliases

### Git Core

| Alias | Command |
|-------|---------|
| `g` | `git` |
| `ga` | `git add` |
| `gaa` | `git add --all` |
| `gc` | `git commit` |
| `gcm` | `git commit -m` |
| `gd` | `git diff` |
| `gds` | `git diff --staged` |
| `gs` | `git status` |
| `gp` | `git push` |
| `gpl` | `git pull` |

### Git GitHub-Style Shortcuts

| Alias | Command |
|-------|---------|
| `gk` | `git checkout` |
| `gr` | `git rebase` |
| `gri` | `git rebase -i` |
| `grc` | `git rebase --continue` |
| `gra` | `git rebase --abort` |
| `gm` | `git merge` |
| `gma` | `git merge --abort` |
| `gcp` | `git cherry-pick` |
| `gf` | `git fetch` |
| `gfa` | `git fetch --all` |
| `gb` | `git branch` |
| `gba` | `git branch -a` |
| `gbd` | `git branch -d` |
| `gbD` | `git branch -D` |
| `gpf` | `git push --force-with-lease` |
| `gpr` | `git pull --rebase` |
| `gprom` | `git pull --rebase origin main` |
| `lg` | `lazygit` |

### Git Workflow

| Alias | Command |
|-------|---------|
| `gwip` | `git add -A && git commit -m "WIP"` |
| `gunwip` | Undo WIP commit |
| `gstash` | `git stash` |
| `gstashp` | `git stash pop` |
| `gstashl` | `git stash list` |
| `glog` | Pretty git log with graph |

### Network

| Alias | Command |
|-------|---------|
| `myip` | Show public IP |
| `localip` | Show local IP |
| `ports` | Show listening ports |
| `listening` | Show LISTEN connections |
| `openports` | Show open ports (sudo) |
| `connections` | Show ESTABLISHED connections |
| `ping` | Ping with 5 packets |
| `speedtest` | Run speed test |
| `flushdns` | Flush DNS cache |

### Navigation & Files

| Alias | Command |
|-------|---------|
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `l` | `ls -lah` |
| `la` | `ls -LA` |
| `ll` | `ls -lF` |

### Docker

| Alias | Command |
|-------|---------|
| `d` | `docker` |
| `dc` | `docker-compose` |
| `dps` | `docker ps` |
| `dpsa` | `docker ps -a` |
| `di` | `docker images` |
| `dex` | `docker exec -it` |

## Cursor Extensions

The following extensions are automatically installed:

- `esbenp.prettier-vscode` - Code formatter
- `formulahendry.docker-explorer` - Docker explorer
- `formulahendry.docker-extension-pack` - Docker extension pack
- `golang.go` - Go language support
- `ms-python.python` - Python language support
- `ms-python.debugpy` - Python debugger
- `ms-python.vscode-pylance` - Python language server
- `nextfaze.json-parse-stringify` - JSON utilities
- `waderyan.gitblame` - Git blame information

## Usage

After installation, restart your terminal or run:

```bash
source ~/.zshrc
```

### Quick Commands

```bash
# Open lazygit
lg

# Checkout a branch
gk feature-branch

# Rebase interactively
gri HEAD~3

# Pull with rebase from origin main
gprom

# Quick WIP commit
gwip
```

### Updating extensions

```bash
cursor --update-extensions
```

## Customization

- **Aliases**: Edit `.aliases` file
- **Extensions**: Modify `EXTENSIONS` array in `init/cursor-extensions.sh`
- **Oh My Posh Theme**: Change theme in `~/.zshrc` or select from `~/.poshthemes/`

## Requirements

- Linux or macOS
- Git
- Cursor (for extensions)
- Internet connection (for downloads)

## License

MIT License - feel free to use and modify as needed.
