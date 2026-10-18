#!/usr/bin/env bash
# 新 Mac 初始化：先准备运行依赖，再安装工具链，最后链接配置。
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ $# -gt 0 ]]; then
  echo "用法：bash bootstrap/run.sh；只读检查用 bash bootstrap/check.sh。" >&2
  exit 2
fi
if [[ "$(uname -s)" != Darwin ]]; then
  echo "该入口仅支持 macOS。" >&2
  exit 1
fi
if [[ -z "${HOME:-}" || "$HOME" != /* || "$HOME" == / ]]; then
  echo "HOME 必须是非根目录的绝对路径。" >&2
  exit 1
fi
# xcode-select 只检查 Command Line Tools；安装需要用户先在系统对话框完成。
if ! xcode-select -p >/dev/null 2>&1; then
  echo "请先执行 xcode-select --install，完成后重试。" >&2
  exit 1
fi
# 子脚本不能把 PATH 传回父进程，因此在总入口先加载 Homebrew 的 shell 环境。
if ! command -v brew >/dev/null 2>&1; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    echo "请先按 https://brew.sh/ 安装 Homebrew。" >&2
    exit 1
  fi
fi
for required_command in git curl; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    echo "缺少前置命令：$required_command" >&2
    exit 1
  fi
done
# 已有 Stow 时先检查冲突，尽量在任何下载安装前发现旧配置。
if command -v stow >/dev/null 2>&1 && [[ -d "$HOME" ]]; then
  bash "$REPO_ROOT/bootstrap/macosinit.sh" check
fi

echo "[1/5] 补装 Homebrew 依赖"
bash "$REPO_ROOT/bootstrap/brew.sh" install
mkdir -p "$HOME"
bash "$REPO_ROOT/bootstrap/macosinit.sh" check
echo "[2/5] 准备 Node 与 npm 工具"
bash "$REPO_ROOT/bootstrap/node.sh" install
echo "[3/5] 补装 Rust 工具链"
bash "$REPO_ROOT/bootstrap/rust.sh" install
echo "[4/5] 补装 oh-my-zsh、主题与插件"
# Node 在独立子进程中激活；补全生成所需的默认版本 PATH 在此重新注入。
if [[ -s "${NVM_DIR:-$HOME/.nvm}/nvm.sh" ]]; then
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  # nvm 是外部脚本，加载时暂时关闭未定义变量检查，随后恢复。
  set +u
  # shellcheck source=/dev/null
  source "$NVM_DIR/nvm.sh" --no-use
  nvm use --silent default
  set -u
fi
export PATH="${CARGO_HOME:-$HOME/.cargo}/bin:$PATH"
bash "$REPO_ROOT/bootstrap/ohmyzsh.sh" install
echo "[5/5] 链接 Zsh 与 Neovim 配置"
bash "$REPO_ROOT/bootstrap/macosinit.sh" install
echo "初始化完成。新开终端后执行 bash bootstrap/check.sh 和 bash bootstrap/brew.sh check。"
