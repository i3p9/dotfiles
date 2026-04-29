# Personal Zsh configuration file. It is strongly recommended to keep all
# shell customization and configuration (including exported environment
# variables such as PATH) in this file or in files sourced from it.
#
# Documentation: https://github.com/romkatv/zsh4humans/blob/v5/README.md.

# Periodic auto-update on Zsh startup: 'ask' or 'no'.
# You can manually run `z4h update` to update everything.
zstyle ':z4h:' auto-update      'no'
# Ask whether to auto-update this often; has no effect if auto-update is 'no'.
zstyle ':z4h:' auto-update-days '28'

# Keyboard type: 'mac' or 'pc'.
zstyle ':z4h:bindkey' keyboard  'mac'

# Don't start tmux (Ghostty handles tabs/splits natively).
zstyle ':z4h:' start-tmux       'no'

# Mark up shell's output with semantic information.
zstyle ':z4h:' term-shell-integration 'yes'

# Right-arrow key accepts one character ('partial-accept') from
# command autosuggestions or the whole thing ('accept')?
zstyle ':z4h:autosuggestions' forward-char 'accept'

# Recursively traverse directories when TAB-completing files.
zstyle ':z4h:fzf-complete' recurse-dirs 'yes'

# Enable direnv to automatically source .envrc files.
zstyle ':z4h:direnv'         enable 'no'
# Show "loading" and "unloading" notifications from direnv.
zstyle ':z4h:direnv:success' notify 'yes'

# Default: don't auto-teleport z4h over SSH.
zstyle ':z4h:ssh:*' enable 'no'

# Install or update core components (fzf, zsh-autosuggestions, etc.) and
# initialize Zsh. After this point console I/O is unavailable until Zsh
# is fully initialized. Everything that requires user interaction or can
# perform network I/O must be done above. Everything else is best done below.
z4h init || return

# Extend PATH.
path=(~/bin $path)

# Export environment variables.
export GPG_TTY=$TTY

# Source additional local files if they exist.
z4h source ~/.env.zsh

# Define key bindings.
z4h bindkey undo Ctrl+/   Shift+Tab  # undo the last command line change
z4h bindkey redo Option+/            # redo the last undone command line change

z4h bindkey z4h-cd-back    Shift+Left   # cd into the previous directory
z4h bindkey z4h-cd-forward Shift+Right  # cd into the next directory
z4h bindkey z4h-cd-up      Shift+Up     # cd into the parent directory
z4h bindkey z4h-cd-down    Shift+Down   # cd into a child directory

# Autoload functions.
autoload -Uz zmv

# Define functions and completions.
function take() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories take

# my aliases
alias bi='brew install'
alias bic='brew install --cask'
alias backup="$HOME/Scripts/rclone/rclone.sh"
alias backup-cloud="$HOME/Scripts/rclone/rclone-drive.sh"
alias please=sudo
alias cd=z

# Define named directories: ~w <=> Windows home directory on WSL.
[[ -z $z4h_win_home ]] || hash -d w=$z4h_win_home

# Define aliases.
alias tree='tree -a -I .git'

# Add flags to existing aliases.
alias ls="${aliases[ls]:-ls} -A"

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu

# Lazy-load nvm: only sourced on first use of nvm/node/npm/npx/pnpm/yarn.
export NVM_DIR="$HOME/.nvm"
_nvm_lazy_load() {
  unset -f nvm node npm npx yarn
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
nvm()  { _nvm_lazy_load; nvm  "$@"; }
node() { _nvm_lazy_load; node "$@"; }
npm()  { _nvm_lazy_load; npm  "$@"; }
npx()  { _nvm_lazy_load; npx  "$@"; }
yarn() { _nvm_lazy_load; yarn "$@"; }
export PATH="/opt/homebrew/opt/python@3.11/libexec/bin:$PATH"
# pnpm
export PNPM_HOME="/Users/fahim/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
eval "$(zoxide init zsh)"

# Lazy-load conda: only initialized on first use of `conda`.
conda() {
  unset -f conda
  __conda_setup="$('/opt/homebrew/Caskroom/miniforge/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__conda_setup"
  elif [ -f "/opt/homebrew/Caskroom/miniforge/base/etc/profile.d/conda.sh" ]; then
    . "/opt/homebrew/Caskroom/miniforge/base/etc/profile.d/conda.sh"
  else
    export PATH="/opt/homebrew/Caskroom/miniforge/base/bin:$PATH"
  fi
  unset __conda_setup
  conda "$@"
}


# bun completions
[ -s "/Users/fahim/.bun/_bun" ] && source "/Users/fahim/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH
# opencode
export PATH=/Users/fahim/.opencode/bin:$PATH

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'; fi

alias claude2="CLAUDE_CONFIG_DIR=~/.claude2 claude"
