#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "[1/3] 初始化 macOS 设置"
bash "$ROOT/bootstrap/macosinit.sh"

echo "[2/3] 安装/配置 Homebrew 依赖"
bash "$ROOT/bootstrap/brew.sh"

echo "[3/3] 安装/配置 Rust 相关"
bash "$ROOT/bootstrap/rust.sh"

echo "✅ bootstrap 完成"
