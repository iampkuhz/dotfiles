# pyenv：Python 多版本管理
# 查看可以安装的版本: pyenv install --list
# 安装: pyenv install 3.XX.XX
# 切换: pyenv global 3.XX.XX
# 查看: pyenv version && python -V
export PYENV_ROOT="$HOME/.pyenv"
path_prepend "$PYENV_ROOT/bin"

# 初始化 pyenv（会设置 shim、hook 等）
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi
