# dotfiles

Personal config managed with [GNU Stow](https://www.gnu.org/software/stow/).
Each top-level folder is a "package" — its contents mirror the path in
`$HOME` where they should be symlinked.

## Layout

| Package   | Symlinks to                                                                         |
| --------- | ----------------------------------------------------------------------------------- |
| `zsh`     | `~/.zshrc`, `~/.zshenv`, `~/.zprofile`                                              |
| `ghostty` | `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty`                |
| `git`     | `~/.gitconfig`, `~/.gitignore_global`, `~/.config/git/ignore`                       |
| `claude`  | `~/.claude/{settings.json,settings.local.json,mcp.json,agents,commands}`            |
| `btop`    | `~/.config/btop/btop.conf`                                                          |
| `mpv`     | `~/.config/mpv/mpv.conf`                                                            |
| `tvnamer` | `~/.config/tvnamer/tvnamer.json`                                                    |
| `ssh`     | `~/.ssh/config` (only — keys live in your password manager)                         |
| `vscode`  | `~/Library/Application Support/Code/User/{settings.json,keybindings.json,snippets}` |
| `server`  | server-side configs (not stowed — copy manually where needed)                       |
| `bettertouchtool` | BTT preset bundle (`.bttpreset`) — imported via the BTT GUI, not stowed       |
| `raycast` | Raycast `.rayconfig` export — imported via the Raycast GUI, not stowed              |
| `iina`    | IINA prefs plist snapshot — imported via `defaults import`, not stowed              |

Top-level files (not stow packages):

| File                  | Purpose                                                     |
| --------------------- | ----------------------------------------------------------- |
| `Brewfile`            | `brew bundle` lockfile (formulae, casks, VS Code, cargo)    |
| `manual-apps.txt`     | Apps installed by hand (App Store, direct downloads)        |
| `dev-versions.txt`    | Snapshot of nvm/pipx versions + global packages             |
| `backup-excludes.txt` | rsync exclude list when copying `$HOME` to a backup drive   |
| `scripts/`            | Helper scripts (e.g. `dump-dev-versions.sh`)                |

## Fresh-machine setup

```sh
# 1. Install Homebrew, then stow + git
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install stow git

# 2. Clone this repo to ~/dotfiles
git clone https://github.com/i3p9/dotfiles.git ~/dotfiles

# 3. Symlink everything into $HOME
cd ~/dotfiles
stow zsh ghostty git claude btop mpv tvnamer ssh vscode

# 4. Install everything in the Brewfile (formulae, casks, VS Code extensions)
brew bundle --file=~/dotfiles/Brewfile

# 5. Install the apps in `manual-apps.txt` by hand (App Store + direct downloads)

# 6. Restore SSH keys from Bitwarden into ~/.ssh/ (see "SSH keys" section below)

# 7. Re-import GUI app configs:
#    - BetterTouchTool: open the .bttpreset in `bettertouchtool/` (BTT → Manage Presets → Import)
#    - Raycast: open the .rayconfig in `raycast/` (Raycast → Settings → Advanced → Import)
#    - IINA: defaults import com.colliderli.iina ~/dotfiles/iina/com.colliderli.iina.plist
#      (quit IINA first; then `killall cfprefsd` so it picks up the new plist)

# 8. Reinstall Node versions + globals from dev-versions.txt
#    (e.g. nvm install 24, then npm i -g <packages>)

# 9. Apply macOS preferences (Dock, Finder, screenshots, etc.):
~/dotfiles/scripts/macos-defaults.sh

# 10. Restore custom fonts (binaries kept out of repo — see fonts.txt):
cp ~/Keys/fonts/*.{otf,ttf} ~/Library/Fonts/

# 11. Restore secrets (NOT in this repo — kept separately)
#     Copy your ~/.env.zsh from secure backup. ~/.zshrc sources it.

# 12. Open a new shell. Done.
```

## Updating the Brewfile

Re-dump after you `brew install`/`uninstall` something so the lockfile matches reality:

```sh
brew bundle dump --describe --file=~/dotfiles/Brewfile --force
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

## Exporting GUI app configs

These can't be safely symlinked (live SQLite DBs, encrypted state). Re-export
after meaningful changes.

**BetterTouchTool** — `BTT menubar → Manage Presets → Export`. Save the
`.bttpreset` into `bettertouchtool/` and commit. Restore: double-click the file
or `Manage Presets → Import`.

**Raycast** — `Raycast → Settings → Advanced → Export`. Choose a password
(remember it — the file is encrypted with it). Save the `.rayconfig` into
`raycast/` and commit. Restore: `Settings → Advanced → Import`, enter password.

**IINA** — preferences plist (UI layout, keybinds, plugin toggles). Re-export
from the CLI after meaningful changes:

```sh
defaults export com.colliderli.iina ~/dotfiles/iina/com.colliderli.iina.plist
```

The actual mpv settings IINA uses live in `~/.config/mpv/mpv.conf` (the `mpv`
package — already stowed). IINA reads that path because `useUserDefinedConfDir`
is on. Plugin auth state (e.g. Jellyfin session token, OpenSubtitles login)
is intentionally **not** captured — re-authenticate after restore.

## SSH keys

Keys are **never** committed to this repo (`.gitignore` blocks `ssh/.ssh/*`
except `config`). The config is stowed; the keys must be restored from a
password manager.

Current keys referenced in `ssh/.ssh/config`:

| Key file               | Used for                  |
| ---------------------- | ------------------------- |
| `~/.ssh/id_ed25519`    | github.com                |
| `~/.ssh/hetzner`       | Hetzner server (5.78.…)   |
| `~/.ssh/id_homelab`    | `lab` host                |

**How to back up:** in Bitwarden, create a Secure Note per key (or use the
file-attachment feature). Paste the private key contents and store the
passphrase in the same note. Do **not** rely on the SSD copy alone — encrypted
password manager is the source of truth.

**Restore on a fresh machine:**

```sh
mkdir -p ~/.ssh && chmod 700 ~/.ssh
# Paste each private key from Bitwarden into ~/.ssh/<name>, then:
chmod 600 ~/.ssh/id_ed25519 ~/.ssh/hetzner ~/.ssh/id_homelab
chmod 644 ~/.ssh/*.pub 2>/dev/null || true

# Add to ssh-agent + macOS Keychain (passphrase prompt happens once):
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
ssh-add --apple-use-keychain ~/.ssh/hetzner
ssh-add --apple-use-keychain ~/.ssh/id_homelab

# Smoke-test:
ssh -T git@github.com
```

The stowed `~/.ssh/config` already has `UseKeychain yes` + `AddKeysToAgent yes`
on the `github.com` block, so passphrases get cached automatically going
forward.

## Backing up `$HOME` to an external drive

Use the wrapper script — backs up only the visible top-level folders
(`codes`, `Documents`, `Downloads`, `Movies`, `Music`, `Pictures`, `dotfiles`,
`Keys`, etc.) and skips all hidden dotdirs, `bin`, `opt`, `Applications`,
`Library`, `overrides_chrome`, plus recursive junk (`node_modules`, build
caches, `.DS_Store`):

```sh
# Always dry-run first
~/dotfiles/scripts/backup-home.sh /Volumes/BackupSSD/home --dry-run

# Then for real
~/dotfiles/scripts/backup-home.sh /Volumes/BackupSSD/home
```

The script uses `--delete` to mirror — anything in the destination that's no
longer in `$HOME` gets removed. To tweak what's included/excluded, edit
`backup-excludes.txt`. The Library exclude is broad — if a specific app stores
data there that you care about, export it explicitly (BTT/Raycast already
have a workflow above; for postgres-app, run `pg_dumpall`).

## Secrets

Secrets live in `~/.env.zsh` (sourced by `.zshrc`). That file is **not**
in this repo. Back it up separately (password manager, encrypted vault,
or private repo).
