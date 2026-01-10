# nvm：Node 多版本管理（通过 source 脚本加载）
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Grammarly LSP 在 Node v24 下偶发 wasm 路径解析报错
# 这里用 nvm 优先探测 Node 20/22，并导出给 Neovim 的 Grammarly 进程使用
grammarly_node_path=""
if command -v nvm >/dev/null 2>&1; then
  # 先尝试 20，再尝试 22；不要求设为默认版本
  grammarly_node_path="$(nvm which 20 2>/dev/null)"
  if [ -z "$grammarly_node_path" ] || [ ! -x "$grammarly_node_path" ]; then
    grammarly_node_path="$(nvm which 22 2>/dev/null)"
  fi
fi
if [ -n "$grammarly_node_path" ] && [ -x "$grammarly_node_path" ]; then
  export GRAMMARLY_NODE_PATH="$grammarly_node_path"
fi
