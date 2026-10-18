#!/usr/bin/env bash
# 只检查文件、语法与命令路径；不加载 .zshrc，不安装、不启动服务、不访问网络。
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
result=0
# Bash 的 -n 每次只检查一个脚本，因此不能简单传入 bootstrap/*.sh。
for script_file in "$REPO_ROOT"/bootstrap/*.sh "$REPO_ROOT"/services/podman/*.sh; do
  bash -n "$script_file" || result=1
done
# ShellCheck 只读取脚本，发现问题时累积失败状态，不在检查入口安装工具。
if command -v shellcheck >/dev/null 2>&1; then
  shellcheck "$REPO_ROOT"/bootstrap/*.sh "$REPO_ROOT"/services/podman/*.sh || result=1
fi
for required_command in git brew stow nvim tree-sitter shellcheck shfmt python3 uv node npm prettier prettierd yarn rustup rustfmt; do
  if command -v "$required_command" >/dev/null 2>&1; then
    echo "可用：$required_command ($(command -v "$required_command"))"
  else
    echo "缺少：$required_command" >&2
    result=1
  fi
done
# -ef 比较最终文件，兼容旧版目录链接和新版逐文件链接，但不接受独立拷贝。
for config_file in .zshrc .zsh_config/00-core.zsh .config/nvim/init.vim .config/nvim/lazy-lock.json; do
  case "$config_file" in
  .config/*) source_file="$REPO_ROOT/neovim/$config_file" ;;
  *) source_file="$REPO_ROOT/zsh/$config_file" ;;
  esac
  if [[ "$HOME/$config_file" -ef "$source_file" ]]; then
    echo "链接正确：$config_file"
  else
    echo "链接缺失或来源不符：$HOME/$config_file" >&2
    result=1
  fi
done
if [[ ! -s "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
  echo "缺少 oh-my-zsh；执行 bash bootstrap/ohmyzsh.sh install。" >&2
  result=1
fi
echo "共享/单机软件清单另用 bash bootstrap/brew.sh check 检查；Java/GUI 按需人工检查。"
exit "$result"
