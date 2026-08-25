# iampkuhz dotfiles

```bash
# stow 管理: brew install stow

# 安装 zsh & neovim
stow -v zsh neovim

# 安装 continue
stow --no-folding -t ~ continue
# 需要手工copy .env 文件，才能被 continue 插件加载
ln -sf "$HOME/.env" "$HOME/.continue/.env"

```

## macOS 新机初始化

先按 [Homebrew 官方说明](https://brew.sh/) 安装 Homebrew，再执行：

```bash
bash bootstrap/run.sh
```

`bootstrap/run.sh` 会依次处理 macOS 配置、Homebrew 依赖、Rust 和 oh-my-zsh。
根目录 `Brewfile` 保存多台 Mac 共用的软件；仅当前机器需要的软件放在已忽略的
`Brewfile.local`。默认安装入口只补装缺失依赖，不主动升级现有软件。

Homebrew 依赖也可以单独维护：

```bash
bash bootstrap/brew.sh check    # 只检查
bash bootstrap/brew.sh install  # 补装缺失依赖
bash bootstrap/brew.sh upgrade  # 显式升级清单内依赖
```

不要用 `brew bundle dump --force` 覆盖共享清单，也不要自动执行
`brew bundle cleanup --force`，以免混入或误删当前机器的软件。
