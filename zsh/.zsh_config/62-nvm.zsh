# nvm：Node 多版本管理
# 启动加速策略：zsh 启动时不立即 source nvm.sh，而是在首次用到 nvm/node/npm/npx 时再加载。
: "${NVM_DIR:="$HOME/.nvm"}"

_lazy_load_nvm() {
  # 防止重复加载：第一次加载完成后移除函数包装。
  unset -f nvm node npm npx _lazy_load_nvm

  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  # 如果你需要 nvm 自带补全，再按需打开下一行（会略微增加首次加载耗时）。
  # [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

# 用同名函数占位：第一次调用时先加载 nvm，再继续执行原命令。
nvm() {
  _lazy_load_nvm
  nvm "$@"
}
node() {
  _lazy_load_nvm
  node "$@"
}
npm() {
  _lazy_load_nvm
  npm "$@"
}
npx() {
  _lazy_load_nvm
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
