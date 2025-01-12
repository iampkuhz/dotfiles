#!/bin/bash

# 获取脚本所在目录（即 dotfiles 项目目录）
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "current dir:${DOTFILES_DIR}"

# 创建软链接的函数
create_symlink() {
  local src_path="$DOTFILES_DIR/../$1"
  local dest_path="$2"
  local hint="$3"

  # 检查源文件是否存在
  if [[ ! -e "$src_path" ]]; then
    echo "Warning: $src_path does not exist, skipping..."
    return
  fi

  # 检查目标路径的父文件夹是否存在
  local parent_dir
  parent_dir="$(dirname "$dest_path")"
  if [[ ! -d "$parent_dir" ]]; then
    echo "Error: Parent directory $parent_dir does not exist. Aborting..."
    exit 1
  fi

  # 如果目标路径已存在，则中断操作
  if [[ -e "$dest_path" || -L "$dest_path" ]]; then
    echo "Error: Destination path $dest_path already exists. Aborting..."
    exit 1
  fi

  # 创建软链接
  ln -s "$src_path" "$dest_path"
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to create symlink for $hint. Aborting..."
    exit 1
  fi
  echo "$hint Linked succeed: $src_path -> $dest_path"
}

create_symlink "neovim/" "$HOME/.config/nvim" "neovim"

echo "All done!"
