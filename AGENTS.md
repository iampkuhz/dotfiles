# Repository Guidelines

## 项目结构与模块组织
- `bootstrap/`：macOS、Homebrew、Rust 等初始化脚本。
- `zsh/`：Zsh 配置（`.zshrc`、`.zsh_config/`），通过 GNU Stow 管理。
- `neovim/`：Neovim 配置根目录 `neovim/.config/nvim/`（Lua、`init.vim`、格式化配置、`lazy-lock.json`）。
- `continue/`：Continue 插件配置在 `continue/.continue/`。
- `tmp/`：临时目录，不作为配置来源。

## 构建、测试与开发命令
- `stow -v zsh neovim`：通过软链安装 zsh 与 Neovim 配置。
- `stow --no-folding -t ~ continue`：安装 Continue 配置；并链接环境变量文件：`ln -sf "$HOME/.env" "$HOME/.continue/.env"`。
- `bash bootstrap/run.sh`：完整初始化（macOS 设置、Homebrew 依赖、Rust 工具链）。
- `bash bootstrap/macosinit.sh`：将 Neovim 配置链接到 `~/.config/nvim`。
- `bash bootstrap/brew.sh`：安装命令行工具和格式化依赖。

## 编码风格与命名规范
- Bash 脚本优先使用 `set -euo pipefail`；缩进 2 空格；函数用 `snake_case` 命名。
- Lua 配置遵循 `stylua` 默认风格；模块路径放在 `neovim/.config/nvim/lua/`。
- 新脚本文件使用小写、可读的命名（如 `bootstrap/tooling.sh`）。

## 配置新增与注释要求（重要）
- 任何新增配置必须附带中文解释说明，避免只写“裸配置”。
- 当出现首次使用的配置格式/语法（如某类 `zstyle`、`eval "$(tool init)"`、`export` 组合写法等），必须添加中文注释说明其语义与用途。
- 你对 Bash 命令熟悉，但对 Bash 脚本语义不熟悉：脚本里出现的关键流程（条件判断、循环、子进程、环境变量持久化等）要用简短中文注释解释。
- 注释尽量多，可以连续多行都有注释。但是对于非常简单、重复出现的格式，不需要重复注释

## 测试与验证
- 本仓库没有自动化测试。
- 修改 shell 脚本后建议运行：`bash -n bootstrap/*.sh`。
- 修改配置后用 stow 重新链接，并启动对应工具验证（zsh 或 Neovim）。

## 提交与 PR 规范
- 现有提交信息简短直接（多为中文）；保持风格一致，不强制 Conventional Commits。
- PR 需包含：变更目的、影响范围（如 `zsh/`、`neovim/`）以及合并后的手工步骤。

## 安全与配置提示
- 避免提交密钥；`.env` 应保存在 `$HOME`，并通过软链提供给 Continue。
- 初始化脚本会安装 Homebrew 和 Rustup 相关工具，仅在可信机器上运行。
