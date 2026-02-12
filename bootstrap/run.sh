#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "[1/4] 初始化 macOS 设置"
bash "$ROOT/bootstrap/macosinit.sh"

echo "[2/4] 安装/配置 Homebrew 依赖"
bash "$ROOT/bootstrap/brew.sh"

echo "[3/4] 安装/配置 Rust 相关"
bash "$ROOT/bootstrap/rust.sh"

echo "[4/4] 安装/配置 oh-my-zsh 与插件"
bash "$ROOT/bootstrap/ohmyzsh.sh"

echo "✅ bootstrap 完成"
