# Rust
path_prepend "$HOME/.cargo/bin"

# Perl（用于 LaTeX format）
path_prepend "/opt/homebrew/opt/perl/bin"

# Solana CLI
path_prepend "$HOME/.local/share/solana/install/active_release/bin"

# postgresql
#只有安装了 postgresql@18 才加到环境变量里面
# 启动： brew services start postgresql@18

if command -v brew >/dev/null 2>&1 && brew --prefix postgresql@18 >/dev/null 2>&1; then
  local _pg_bin
  _pg_bin="$(brew --prefix postgresql@18)/bin"
  if [[ -d "${_pg_bin}" ]]; then
    path=("${_pg_bin}" $path)
  fi
  unset _pg_bin
fi

