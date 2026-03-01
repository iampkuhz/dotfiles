#!/usr/bin/env bash
set -euo pipefaik

# ===========================================================================
# Homebrew 工具安装脚本
# ===========================================================================

# yarn：包管理器，使用 nvm 管理的 node（不安装 homebrew node）
brew install yarn yamlfmt pdf2svg

# 代码 formatter 工具（neovim 的 conform.nvim 等插件会调用）
# 【注意】prettier/prettierd 不通过 brew 安装，因为它们会引入 homebrew node 依赖，
# 与 nvm 管理的 node 冲突。改为通过 npm 全局安装，见下方 npm_global_install 函数。
brew install shfmt stylua

# 其他常用工具
brew install imagemagick grip wget podman-compose


# ===========================================================================
# npm 全局工具安装（需要先通过 nvm 安装 node）
# ===========================================================================
npm_global_install() {
  # 检查 npm 命令是否可用（需要先安装 nvm 并设置默认版本）
  if ! command -v npm >/dev/null 2>&1; then
    echo "⚠️  npm 未找到，请先安装 nvm 并设置默认 node 版本："
    echo "   1. 运行: bash bootstrap/ohmyzsh.sh（会提示安装 nvm）"
    echo "   2. 然后: nvm install --lts && nvm alias default <版本>"
    echo "   3. 最后重新运行本脚本"
    return 1
  fi
  echo "通过 npm 安装全局工具..."
  # prettier: 代码格式化
  # @fsouza/prettierd: prettier 的守护进程版本，启动更快
  npm install -g prettier @fsouza/prettierd
}

# 执行 npm 全局安装（如果 npm 可用）
npm_global_install || true

echo "✅ brew.sh 安装完成"
