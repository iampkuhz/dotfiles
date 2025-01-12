# 检查是否已安装 Rust
if command -v rustup >/dev/null 2>&1; then
  echo "Rust is already installed. Upgrading Rust..."
  rustup update
else
  echo "Installing Rust toolchain..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# 检查 Rust 环境变量是否已添加
if ! grep -q "$HOME/.cargo/bin" <<< "$PATH"; then
  echo "Adding Rust environment variables to PATH..."
  export PATH="$HOME/.cargo/bin:$PATH"

  # 持久化到 Shell 配置文件
  if [[ -f "$HOME/.bashrc" ]]; then
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$HOME/.bashrc"
    # 立即加载 Rust 环境
    source "$HOME/.bashrc"
  elif [[ -f "$HOME/.zshrc" ]]; then
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$HOME/.zshrc"
    # 立即加载 Rust 环境
    source "$HOME/.zshrc"
  else
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$HOME/.profile"
    # 立即加载 Rust 环境
    source "$HOME/.profile"
  fi
fi


# 安装rust formatter，neovim的formatter插件（conform.nvim等）会用到
rustup component add rustfmt
