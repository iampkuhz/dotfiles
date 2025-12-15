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
