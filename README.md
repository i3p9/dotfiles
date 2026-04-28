# dotfiles

Personal config managed with [GNU Stow](https://www.gnu.org/software/stow/).
Each top-level folder is a "package" — its contents mirror the path in
`$HOME` where they should be symlinked.

## Layout

| Package   | Symlinks to                                         |
| --------- | --------------------------------------------------- |
| `zsh`     | `~/.zshrc`, `~/.zshenv`, `~/.zprofile`              |
| `ghostty` | `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` |
| `git`     | `~/.gitconfig`, `~/.gitignore_global`, `~/.config/git/ignore` |
| `server`  | server-side configs (not stowed — copy manually where needed) |

## Fresh-machine setup

```sh
# 1. Install Homebrew, then stow + git
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install stow git

# 2. Clone this repo to ~/dotfiles
git clone https://github.com/i3p9/dotfiles.git ~/dotfiles

# 3. Symlink everything into $HOME
cd ~/dotfiles
stow zsh ghostty git

# 4. Restore secrets (NOT in this repo — kept separately)
#    Copy your ~/.env.zsh from secure backup. ~/.zshrc sources it.

# 5. Open a new shell. Done.
```

## Adding a new package

```sh
mkdir -p ~/dotfiles/<pkg>/<path-relative-to-home>
mv ~/<path>/<file> ~/dotfiles/<pkg>/<path>/<file>
cd ~/dotfiles && stow <pkg>
```

## Removing a package's symlinks

```sh
cd ~/dotfiles && stow -D <pkg>
```

## Secrets

Secrets live in `~/.env.zsh` (sourced by `.zshrc`). That file is **not**
in this repo. Back it up separately (password manager, encrypted vault,
or private repo).
