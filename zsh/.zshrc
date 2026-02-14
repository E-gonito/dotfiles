# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zoxide fzf)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(zoxide init zsh)"

# Added by Antigravity
export PATH="/Users/macbookm1/.antigravity/antigravity/bin:$PATH"

gpx() {
  # --autostash handles the "index contains changes" error by temporary stashing them
  git fetch && git pull --rebase --autostash || {
    echo "❌ Pull failed. Conflict detected."
    return 1
  }
  
  # Now that we are up to date, proceed to UI
  gitui
  
  if git diff --cached --quiet; then
    echo "No files staged. Aborting."
    return 1
  fi

  echo -n "Conventional Commit Message: "
  read msg
  
  git commit -m "$msg" && git push
}

gpa() {
  local DOT_DIR="$HOME/Documents/dotfiles"
  cd "$DOT_DIR" || return 1

  # 1. Sync with remote first (prevents rebase errors)
  # --autostash hides current modifications to allow the pull
  git fetch && git pull --rebase --autostash || {
    echo "❌ Sync failed. Resolve conflicts manually."
    return 1
  }

  # 2. Launch UI for staging (Selection Phase)
  gitui

  # 3. Verify something is actually staged
  if git diff --cached --quiet; then
    echo "No files staged. Aborting."
    return 1
  fi

  # 4. Generate AI Commit Message
  echo "🤖 Fabric is analyzing your diff..."
  local ai_msg=$(git diff --staged | fabric -p create_conventional_commit)

  if [ -z "$ai_msg" ]; then
    echo "❌ Fabric failed to generate a message."
    return 1
  fi

  # 5. Clean and Confirm
  # Strips 'git commit -m' and quotes if Fabric included them
  local clean_msg=$(echo "$ai_msg" | sed -E 's/^git commit -m "//; s/"$//')
  
  echo "✨ AI Suggestion: $clean_msg"
  echo -n "Confirm commit and push? (y/n): "
  read choice

  if [[ "$choice" == "y" ]]; then
    git commit -m "$clean_msg" && git push
  else
    echo "🚫 Commit aborted."
  fi
}

dots() {
  local DOT_DIR="$HOME/Documents/dotfiles"
  cd "$DOT_DIR" || return 1

  # Step A: Sync with remote BEFORE we change the Brewfile/extensions
  # This prevents the "index contains changes" error
  git fetch && git pull --rebase --autostash

  # Step B: Clean and Update
  find . -name ".DS_Store" -delete
  brew bundle dump --force --file="./Brewfile"
  code --list-extensions > "./vscode/Library/Application Support/Code/User/extensions.txt"
  
  # Step C: Stage everything (including the new Brewfile/extensions)
  git add -A

  # Step D: Refresh Symlinks
  stow -R -v -t ~ zsh
  stow -R -v -t ~ vscode
  
  # Step E: Commit and Push
  gpx
}

# bun completions
[ -s "/Users/macbookm1/.bun/_bun" ] && source "/Users/macbookm1/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
alias ni="bun install"
alias nr="bun run"
alias nx="bunx" # Replaces npx
alias nd="bun dev"
export PATH="$HOME/.local/bin:$PATH"
