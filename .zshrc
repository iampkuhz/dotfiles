export ZSH="$HOME/.oh-my-zsh"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# 本机请求不走代理
export NO_PROXY=127.0.0.1,localhost
export no_proxy=$NO_PROXY


ZSH_THEME="spaceship"

# zsh 更新频率，13天一次
zstyle ':omz:update' frequency 13

# 关闭自动转义字符串，
DISABLE_MAGIC_FUNCTIONS="true"

# 自动纠错
ENABLE_CORRECTION="true"

HIST_STAMPS="yyyy-mm-dd"

plugins=(
  git
  # 当前行的代码补全提示，按 → 补全
  zsh-autosuggestions

  #zsh-syntax-highlighting
  # 和zsh-syntax-highlighting 二选一，fast高亮更多
  fast-syntax-highlighting

  zsh-autocomplete

  kubectl
  # https://github.com/Katrovsky/zsh-ollama-completion
  ollama
)


source $ZSH/oh-my-zsh.sh

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/opt/homebrew/share/zsh-syntax-highlighting/highlighters
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

alias vim="nvim"
alias vi="nvim"

export HOMEBREW_AUTO_UPDATE_SECS="604800"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# homebrew 国内源
## 推荐放到 ~/.zshrc 或 ~/.bashrc
export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"

# zsh-autocomplete 配置第一次tab补全到最长前缀，后续有歧义的话不论怎么按tab都不会自动补全
# all Tab widgets
zstyle ':autocomplete:*complete*:*' insert-unambiguous yes
# all history widgets
zstyle ':autocomplete:*history*:*' insert-unambiguous yes
zstyle ':autocomplete:menu-search:*' insert-unambiguous yes
zstyle ':completion:*:*' matcher-list 'm:{[:lower:]-}={[:upper:]_}' '+r:|[.]=**'
bindkey '^I' expand-or-complete-prefix

# python 使用pyenv 管理, brew install pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
export PATH="$HOME/.cargo/bin:$PATH"

export AI_PROVIDER="ollama"
# export AI_PROVIDER="openai"
export OPENAI_API_KEY="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"
export OPENAI_MODEL=gpt-5-nano
export OPENAI_BASE_URL=https://api.openai.com/v1
export OLLAMA_ENDPOINT="http://127.0.0.1:11434/v1/completions"
export OLLAMA_COMPLETION_MODEL="qwen2.5-coder-feipi:0.5b_boost2"

export GITHUB_TOKEN='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'
