# =========================
# 1) 加载全局私有环境变量文件：~/.env（不进 git）
# =========================
ZSH_ENV_FILE="$HOME/.env"
if [[ -r "$ZSH_ENV_FILE" ]]; then
  set -a          # 自动 export 该文件里定义的变量
  source "$ZSH_ENV_FILE"
  set +a
fi

# =========================
# 2) 加载模块化配置：~/.zsh_config/*.zsh（可进 git）
# =========================
ZSH_CONFIG_DIR="$HOME/.zsh_config"
if [[ -d "$ZSH_CONFIG_DIR" ]]; then
  for f in "$ZSH_CONFIG_DIR"/*.zsh(N); do
    source "$f"
  done
fi
