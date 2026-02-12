# oh-my-zsh 主目录
export ZSH="$HOME/.oh-my-zsh"

# 主题
ZSH_THEME="spaceship"

# oh-my-zsh 更新频率：13 天一次
zstyle ':omz:update' frequency 13

# 关闭自动转义字符串
DISABLE_MAGIC_FUNCTIONS="true"

# 自动纠错
ENABLE_CORRECTION="false"

# 历史记录时间戳格式
HIST_STAMPS="yyyy-mm-dd"

# 插件列表
plugins=(
  # 以下插件由 oh-my-zsh 内置，主要用于补全与常用别名。
  # 这类命令可以直接通过 plugins 参数启用，不需要额外安装第三方插件仓库。
  git
  kubectl
  aws
  brew
  docker
  docker-compose
  gh
  helm
  node
  npm
  pip
  poetry
  python
  rust
  terraform
  uv
  yarn

  # 以下是第三方增强插件（需要 bootstrap/ohmyzsh.sh 安装到 custom/plugins）。

  # 当前行补全提示，按 → 接受
  zsh-autosuggestions

  # 高亮（与 zsh-syntax-highlighting 二选一）
  fast-syntax-highlighting

  # 更强的补全体验
  zsh-autocomplete

  # https://github.com/Katrovsky/zsh-ollama-completion
  ollama
)

# codex 补全插件由 bootstrap/ohmyzsh.sh 生成到 custom/plugins/codex。
# 为了避免首次启动时出现 `[oh-my-zsh] plugin 'codex' not found`，这里按文件存在再启用。
_codex_plugin_file="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/codex/codex.plugin.zsh"
if [[ -r "$_codex_plugin_file" ]]; then
  plugins+=(codex)
fi
unset _codex_plugin_file

# 加载 oh-my-zsh（必须在 plugins / theme 之后）
source "$ZSH/oh-my-zsh.sh"
