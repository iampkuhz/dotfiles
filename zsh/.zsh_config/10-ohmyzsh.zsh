# oh-my-zsh 主目录
export ZSH="$HOME/.oh-my-zsh"

# 主题
ZSH_THEME="spaceship"

# oh-my-zsh 更新频率：13 天一次
zstyle ':omz:update' frequency 13

# 关闭自动转义字符串
DISABLE_MAGIC_FUNCTIONS="true"

# 自动纠错
ENABLE_CORRECTION="true"

# 历史记录时间戳格式
HIST_STAMPS="yyyy-mm-dd"

# 插件列表
plugins=(
  git
  # 当前行补全提示，按 → 接受
  zsh-autosuggestions

  # 高亮（与 zsh-syntax-highlighting 二选一）
  fast-syntax-highlighting

  # 更强的补全体验
  zsh-autocomplete

  kubectl

  # https://github.com/Katrovsky/zsh-ollama-completion
  ollama
)

# 加载 oh-my-zsh（必须在 plugins / theme 之后）
source "$ZSH/oh-my-zsh.sh"
