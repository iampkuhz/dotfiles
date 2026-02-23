#!/usr/bin/env bash
set -euo pipefail

# 这个脚本负责安装/更新 oh-my-zsh 及当前仓库 zsh 配置依赖的外部主题/插件。
# 设计为可重复执行：已存在时走更新，不存在时才克隆。

ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$ZSH_DIR/custom}"

# 统一处理「目录不存在则 clone，目录存在则 pull」的逻辑，避免重复代码。
install_or_update_repo() {
  local repo_url="$1"
  local target_dir="$2"

  if [[ -d "$target_dir/.git" ]]; then
    echo "更新: $target_dir"
    git -C "$target_dir" pull --ff-only
  else
    echo "安装: $target_dir"
    # 使用浅克隆减少首次安装时间和流量。
    git clone --depth=1 "$repo_url" "$target_dir"
  fi
}

if ! command -v git >/dev/null 2>&1; then
  echo "错误: 未检测到 git，请先安装 git 后再执行。"
  exit 1
fi

# 先准备 oh-my-zsh 主体目录；后续主题与插件都依赖该目录结构。
install_or_update_repo "https://github.com/ohmyzsh/ohmyzsh.git" "$ZSH_DIR"

# 确保 custom 目录存在；主题和第三方插件统一放在这里，避免污染主仓库。
mkdir -p "$ZSH_CUSTOM_DIR/themes" "$ZSH_CUSTOM_DIR/plugins"

# 安装 spaceship 主题，并创建 oh-my-zsh 可识别的主题软链名称。
install_or_update_repo \
  "https://github.com/spaceship-prompt/spaceship-prompt.git" \
  "$ZSH_CUSTOM_DIR/themes/spaceship-prompt"
ln -sfn \
  "$ZSH_CUSTOM_DIR/themes/spaceship-prompt/spaceship.zsh-theme" \
  "$ZSH_CUSTOM_DIR/themes/spaceship.zsh-theme"

# 安装 zsh 配置中声明的外部插件（内置插件 git/kubectl 不需要单独安装）。
install_or_update_repo \
  "https://github.com/zsh-users/zsh-autosuggestions.git" \
  "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
install_or_update_repo \
  "https://github.com/zdharma-continuum/fast-syntax-highlighting.git" \
  "$ZSH_CUSTOM_DIR/plugins/fast-syntax-highlighting"
install_or_update_repo \
  "https://github.com/marlonrichert/zsh-autocomplete.git" \
  "$ZSH_CUSTOM_DIR/plugins/zsh-autocomplete"
install_or_update_repo \
  "https://github.com/Katrovsky/zsh-ollama-completion.git" \
  "$ZSH_CUSTOM_DIR/plugins/ollama"

# Codex 不是 oh-my-zsh 内置插件，这里直接生成一个 custom plugin 文件。
# 这样在 zsh 的 plugins=(codex) 里声明后即可自动加载，无需手工 source。
mkdir -p "$ZSH_CUSTOM_DIR/plugins/codex"
cat >"$ZSH_CUSTOM_DIR/plugins/codex/codex.plugin.zsh" <<'EOF'
# 仅在 codex 命令存在时启用补全，避免未安装 codex 时启动报错。
(( $+commands[codex] )) && eval "$(codex completion zsh)"
EOF

# OpenClaw 也采用同样方式：把补全注册放到 custom plugin 中，统一由 oh-my-zsh 管理加载时机。
# 这样即使机器上暂时没有 openclaw，也不会在 shell 启动时报错。
mkdir -p "$ZSH_CUSTOM_DIR/plugins/openclaw"
cat >"$ZSH_CUSTOM_DIR/plugins/openclaw/openclaw.plugin.zsh" <<'EOF'
# 仅在 openclaw 命令存在时启用补全，避免未安装 openclaw 时启动报错。
# OpenClaw 新版 completion 子命令使用 `--shell` 指定类型（默认 zsh）。
# 启动阶段静默 stderr，避免本地 openclaw 配置不完整时污染终端输出。
(( $+commands[openclaw] )) && eval "$(openclaw completion --shell zsh 2>/dev/null)"
EOF

echo "✅ oh-my-zsh 与相关插件安装/更新完成"
