# nvm：Node 多版本管理
# 启动加速策略：zsh 启动时不立即 source nvm.sh，而是在首次用到 nvm/node/npm/npx 时再加载。
: "${NVM_DIR:="$HOME/.nvm"}"

# 每个 wrapper 自包含 lazy-load 逻辑，不依赖任何外部函数。
# 这样在 Claude Code shell snapshot 恢复时也不会因缺失 helper 函数而报错。
nvm() {
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  unset -f nvm node npm npx
  nvm "$@"
}
node() {
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  unset -f nvm node npm npx
  node "$@"
}
npm() {
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  unset -f nvm node npm npx
  npm "$@"
}
npx() {
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  unset -f nvm node npm npx
  npx "$@"
}

# Grammarly LSP 在 Node v24 下偶发 wasm 路径解析报错。
# 启动加速：这里不调用 `nvm which`，直接按目录优先探测 v20，再探测 v22。
if [[ -z "${GRAMMARLY_NODE_PATH:-}" ]]; then
  _grammarly_node_path=""

  for _node_candidate in "$NVM_DIR"/versions/node/v20*/bin/node(N) "$NVM_DIR"/versions/node/v22*/bin/node(N); do
    if [[ -x "$_node_candidate" ]]; then
      _grammarly_node_path="$_node_candidate"
      break
    fi
  done

  if [[ -n "$_grammarly_node_path" ]]; then
    export GRAMMARLY_NODE_PATH="$_grammarly_node_path"
  fi

  unset _grammarly_node_path _node_candidate
fi
