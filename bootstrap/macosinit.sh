#!/usr/bin/env bash
# 配置链接的唯一入口；Stow 根据包内目录层级定位 ~/.config/nvim 等目标。
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:-install}"
if [[ "$MODE" != install && "$MODE" != check ]]; then
  echo "用法：bash bootstrap/macosinit.sh [install|check]" >&2
  exit 2
fi
if [[ -z "${HOME:-}" || "$HOME" != /* || "$HOME" == / ]]; then
  echo "HOME 必须是非根目录的绝对路径。" >&2
  exit 1
fi
if ! command -v stow >/dev/null 2>&1; then
  echo "缺少 stow，请先执行 bash bootstrap/brew.sh install。" >&2
  exit 1
fi
# 新 HOME 可以尚不存在；只读检查不创建目录，安装模式才准备父目录。
if [[ "$MODE" == install ]]; then
  mkdir -p "$HOME"
elif [[ ! -d "$HOME" ]]; then
  echo "HOME 尚不存在：$HOME" >&2
  exit 1
fi

# Stow 不接管绝对路径链接；已经指向正确配置的链接直接保留，包括旧式目录链接。
# 数组让每项参数独立传递，HOME 或仓库路径带空格时也不会被拆开。
stow_args=(--dir="$REPO_ROOT" --target="$HOME" --no-folding)
preserve_correct_link() {
  local target_path="$1" source_path="$2" ignore_pattern="$3"
  if [[ -L "$HOME/$target_path" && "$HOME/$target_path" -ef "$REPO_ROOT/$source_path" ]]; then
    stow_args+=("--ignore=$ignore_pattern")
  fi
}
preserve_correct_link .zshrc zsh/.zshrc '^\.zshrc$'
preserve_correct_link .zsh_config zsh/.zsh_config '^\.zsh_config$'
preserve_correct_link bin zsh/bin '^bin$'
preserve_correct_link .config neovim/.config '^\.config$'
preserve_correct_link .config/nvim neovim/.config/nvim '^\.config/nvim$'

# 固定工作目录和目标，覆盖 .stowrc 中的默认 HOME；不使用 --adopt/--override。
# 先整体模拟，任一真实文件或错误链接冲突时退出，避免只链接了一半。
cd "$REPO_ROOT"
# 仅向 Stow 子进程移除 HOME，屏蔽用户级 ~/.stowrc 的 adopt/override/ignore 设置。
# 仓库 .stowrc 仍生效；链接目标始终由上面显式的 --target 指定。
env -u HOME stow "${stow_args[@]}" --simulate zsh neovim
if [[ "$MODE" == install ]]; then
  # 不折叠目录：缺失的 .config/nvim 等父目录由 Stow 创建，文件逐个链接。
  env -u HOME stow "${stow_args[@]}" zsh neovim
  echo "配置链接完成；重复执行不会覆盖已有文件。"
else
  echo "配置链接预检通过（仅模拟；不代表配置已安装）。"
fi
