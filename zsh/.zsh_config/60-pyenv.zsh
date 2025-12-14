# pyenv：Python 多版本管理
export PYENV_ROOT="$HOME/.pyenv"
path_prepend "$PYENV_ROOT/bin"

# 初始化 pyenv（会设置 shim、hook 等）
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi
