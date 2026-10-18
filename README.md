# iampkuhz dotfiles

本仓库保存 Mac 研发环境的配置与可重复执行的安装入口。共享依赖写在根目录
`Brewfile`，单机选择写在忽略的 `Brewfile.local`；不从旧机软件快照生成必装清单。

## 新 Mac 初始化

1. 执行 `xcode-select --install`，在系统对话框完成 Command Line Tools 安装。
2. 按 [Homebrew 官方说明](https://brew.sh/) 安装 Homebrew，克隆本仓库。
3. 如需单机软件，复制 `Brewfile.local.example` 为 `Brewfile.local` 并按需取消注释。
4. 在仓库目录运行：

```bash
bash bootstrap/run.sh
```

入口先检查 macOS、Command Line Tools、Homebrew、Git 和 curl。已有 Stow 时会提前
预检配置冲突；随后按 Homebrew → Node/npm → Rust → oh-my-zsh → 配置链接执行。
首次 Homebrew 安装好 Stow 后还会再检查冲突，失败即停止。
不修改系统偏好、不自动启动容器、虚拟机或后台服务。

默认只补装缺失项，保留已有 Node、Rust、主题和插件版本。Homebrew 使用
`bundle install --no-upgrade` 并关闭自动更新；新软件自身要求的依赖仍由 Homebrew 解析。
默认安装不执行 `bundle cleanup`。重复执行不会往 `.zshrc`、`.profile` 等启动文件追加配置。

## 配置链接与冲突

统一入口如下，可独立于全量安装运行：

```bash
bash bootstrap/macosinit.sh check    # 仅模拟，检查是否有冲突
bash bootstrap/macosinit.sh install  # 安全链接 zsh 与 neovim 两个 Stow 包
```

真正的 Neovim 配置是 `neovim/.config/nvim/`；安装后
`~/.config/nvim/init.vim` 应解析到这个目录下的文件。新 HOME 的父目录会自动准备，
新安装使用 Stow 逐文件链接，已有正确的文件或目录软链直接复用。
任意真实文件、断链、错误链接冲突会在整体模拟阶段阻止安装，不覆盖、不自动备份或接管。
入口只使用仓库的 Stow 规则，不读取用户级 `~/.stowrc`，避免其中的
`--adopt`、`--override` 或 `--ignore` 改变冲突保护和安装范围。
请先人工检查冲突内容，备份并移走确认不用的配置，再重试。
特别是旧脚本创建的 `~/.config/nvim -> <仓库>/neovim` 属于错误链接，需要人工处理。

`zsh/` 包含 `.zshrc`、`.zsh_config/` 和 `bin/doctor-zsh-config`；
`neovim/` 包含 Neovim 配置和插件锁文件；`qwen/` 是独立的可选 Stow 包，见其 README。
临时下载、音视频及转写产物放在 `tmp/`，不作为配置来源。

## 软件与运行时的归属

| 类别 | 默认行为 | 按需处理 |
| --- | --- | --- |
| Shell / 编辑器 | Git、gh、Stow、Neovim、格式检查工具 | oh-my-zsh 和已启用的第三方主题/插件由脚本补装 |
| Python | Homebrew Python + uv，为本仓库脚本提供基础解释器 | 项目用 `uv sync` 或项目安装说明；pyenv 仅在需要多版本时安装 |
| Node | 优先使用已有 nvm default，其次已有系统 Node；两者都没有才安装 nvm + LTS | 保留现有版本，业务版本按各项目 `.nvmrc` 选择 |
| npm 工具 | 在选定 Node 的全局目录补装 Prettier、prettierd、Yarn classic | Yarn 用于 Neovim Markdown 预览构建；不从旧机恢复全部全局包 |
| Rust | rustup + minimal 工具链 + rustfmt | 使用项目自己的 `rust-toolchain.toml`；初始化不升级现有工具链 |
| Java / Ruby | 不设为默认依赖 | 按项目要求安装 JDK、SDKMAN、rbenv；无 SDKMAN 时不拦截系统 Java 命令 |
| 模型 / 文档 / 视频 | 保留共享清单中的 hf、ffmpeg、yt-dlp、whisper-cpp 等既有能力 | 模型数据不进仓库 |
| 容器 / GUI | Podman + podman-compose，仅安装命令行工具 | Docker Desktop、终端、IDE 等在 `Brewfile.local` 中选择 |

Node 安装入口使用 [nvm 官方 Git 安装方式](https://github.com/nvm-sh/nvm#git-install)，
固定初装标签 `v0.40.8`，直接克隆，不运行会编辑启动文件的安装器。
已有 nvm 但 default 无效时会要求人工修复，避免偷偷切换版本。
已有系统 Node 时不另装 nvm；Node/npm 缺一时会报错。
新终端首次调用 `nvm`、`node`、`npm` 或 `npx` 会按需加载 nvm，后续仍保留真正的
`nvm` 函数；未安装 nvm 时，Node/npm/npx 继续使用系统命令。
如果所选 Node 的安装前缀已有 Homebrew 等方式提供的同名工具，npm 安装与升级都保留
该命令，提示按所属方式维护；不会用 `--force` 抢占链接。
Rust 安装器传入 `--no-modify-path`，PATH 由受管 Zsh 模块提供；已有工具链却没有
可用默认版本时要求先用 `rustup default <已安装版本>` 选择，不自动刷新已有 stable。
如果使用非默认的 `NVM_DIR`、`CARGO_HOME` 等目录，需要自行确保新终端保留相同环境变量。

Java 版本由业务项目决定。使用示例中的 Homebrew JDK 时，按 `brew info openjdk@21`
的提示完成 macOS 注册和 PATH 设置；SDKMAN 不是新机的前置条件。
不要把项目虚拟环境、整个 `node_modules` 或旧机全部 pip/npm 工具当成共享依赖迁移。

## 安装、检查与显式升级

```bash
bash bootstrap/brew.sh check       # 共享清单与可选单机清单，只检查、不安装
bash bootstrap/brew.sh install     # 仅处理 Homebrew；npm 由 node.sh 负责
bash bootstrap/node.sh install     # 先准备 Node，再补装 npm 工具
bash bootstrap/rust.sh install
bash bootstrap/ohmyzsh.sh install

# 以下命令会升级，需主动选择执行
bash bootstrap/brew.sh upgrade
bash bootstrap/node.sh upgrade     # 仅升级上述 npm 工具，不升级 Node/nvm
bash bootstrap/rust.sh upgrade
bash bootstrap/ohmyzsh.sh upgrade
```

Node/nvm 本身的升级按 [nvm 官方文档](https://github.com/nvm-sh/nvm#manual-upgrade) 手工执行，
并明确选择新的 default；不自动复制旧版的全部 npm 全局包。
oh-my-zsh 升级只允许干净仓库的 `git pull --ff-only`。
不要用 `brew bundle dump --force` 覆盖共享清单，也不要执行 `brew bundle cleanup --force`。

新开终端后运行只读检查：

```bash
bash bootstrap/check.sh
bash bootstrap/brew.sh check
```

`check.sh` 检查 Bash 语法、关键命令路径、配置实际来源与 oh-my-zsh 是否存在；
已安装 ShellCheck 时还会检查全部初始化脚本，缺少工具时报告缺项。
它不加载 `.zshrc`、不访问网络、不启动服务。Homebrew 检查单独运行。
检查通过只说明基础安装和链接具备条件，不代表已验证 GUI、业务项目或远端服务。

首次启动 Neovim 会下载 lazy.nvim 与缺失插件，Mason 也可能下载配置中声明的工具。
锁文件 `lazy-lock.json` 需要纳入版本管理；使用 `:Lazy restore` 按锁文件恢复，
主动升级使用 `:Lazy update` 并审查锁文件差异。需要联网验证时再运行 `:checkhealth`，
并实际打开 Markdown 验证预览；初始化脚本本身不启动 Neovim。

## 本地验证与迁移边界

macOS 上安装 ShellCheck 使用 `brew install shellcheck`（已列入共享 Brewfile），
之后执行 `shellcheck bootstrap/*.sh`；ShellCheck 不支持直接检查 Zsh 配置，后者使用 `zsh -n`。

```bash
# 每个脚本分别做语法检查，bash -n 后面多个文件不会全部被检查
for script_file in bootstrap/*.sh services/podman/*.sh; do bash -n "$script_file" || break; done
shfmt -i 2 -d bootstrap/*.sh services/podman/*.sh
# 已安装 ShellCheck 时运行；不要为验证改动而隐式安装工具
shellcheck bootstrap/*.sh services/podman/*.sh
bash bootstrap/test-links.sh
bash bootstrap/test-node.sh

git diff --check
```

`test-links.sh` 只在临时 HOME 内验证首次安装、重复执行、正确旧链接、真实文件冲突、
断链、错误 Neovim 链接和父目录冲突，退出后删除测试目录。不在真实 HOME 重新 Stow。
它还验证用户级 Stow 规则不能接管真实文件或跳过配置。
`test-node.sh` 使用临时 HOME 与离线替身验证四种首次调用、系统 Node 回退和已有工具归属。
全量安装需要在新 Mac 上完成；本机隔离验证不等于真实网络下载/安装验证。

可重建的环境只迁移几 KB 的配置、Compose、启动命令与脚本。
Podman 镜像、容器和虚拟机通过声明重建，不导出几 GB 的运行时文件；
有状态业务数据按业务项目的备份方案独立处理。本仓库不管理业务仓库或 NAS，
`bootstrap/podman.sh` 是可选的 PlantUML 启动命令，不由初始化入口调用。
密钥、`.env`、认证状态、模型和生成物不入 Git，示例环境文件只能放无密钥占位值。

## 高优先级配置恢复

本轮只管理 HHKB/Karabiner、iTerm2 和 Podman 启动配置。其他桌面应用不加入恢复流程。
`desktop/` 保存 JSON 数据；`services/podman/` 保存启动脚本和 LaunchAgent 模板。
不复制字体文件、应用源码、镜像、虚拟机、缓存、会话历史或数据库。

### HHKB 与 iTerm2

先在新 Mac 的 `Brewfile.local` 中选择 `iterm2`、`karabiner-elements` 和
`font-jetbrains-mono-nerd-font`，再按 Homebrew 入口安装。字体使用包名重装，不随仓库保存。

```bash
bash bootstrap/desktop.sh check    # 只检查两个固定文件及目标冲突，不创建 HOME
bash bootstrap/desktop.sh install  # 仅复制小配置；相同内容跳过，冲突不覆盖
```

- `desktop/karabiner/karabiner.json` 保留两个现有配置档，默认选择 `HHKB-test`。
  规则只匹配 vendor 1278 / product 33 的 HHKB；设备更换时需核对这两个值。
  配置保留右 Command 到 Fn 的设备映射，以及现有方向键层。
- Karabiner [不支持用单个 JSON 文件软链实现可靠重载](https://karabiner-elements.pqrs.org/docs/manual/misc/configuration-file-path/)，
  因此恢复入口使用普通文件副本。已自动生成配置的机器需先备份并人工合并，脚本不会接管。
- `desktop/iterm2/profile.json` 只包含字体、颜色、显示和按键设置，剔除用户名路径、命令、环境与历史。
  恢复到 `~/Library/Application Support/iTerm2/DynamicProfiles/dotfiles.json`；在 iTerm2 中选择 `Dotfiles`，
  按需设为默认。原有默认 Profile 和应用偏好数据库不会被替换。
- 两份副本可以由应用正常修改；调整后需审查并手工同步回仓库。恢复脚本不启动或重启应用。

### Podman 启动器与 LaunchAgent

`services/podman/start.sh` 保留本机的四个服务顺序：LiteLLM PostgreSQL、LiteLLM、SearxNG、Crawl4AI。
它只启动已有 machine 和停止的容器；缺失容器会明确报错，不克隆源码、不拉镜像、不隐式创建数据目录。
machine 默认为 `podman-machine-default`，需要其他名称时可设置 `PODMAN_MACHINE`。
该脚本和 LaunchAgent 都不会被 `bootstrap/run.sh` 自动调用。

新机先按服务所属项目的 Compose 说明准备配置、密钥与数据，并重建容器，再手工验证启动器。
只有明确需要登录后自启时，才渲染和安装 LaunchAgent：

```bash
# 先只生成临时文件并校验；-B 禁止 Python 在用户目录生成字节码缓存
python3 -B services/podman/render-agent.py > "$TMPDIR/dotfiles-podman-agent.plist"
plutil -lint "$TMPDIR/dotfiles-podman-agent.plist"
# 以下是新机的主动启用步骤；已有同名文件或服务时先人工核对，不重复创建
mkdir -p "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
cp -n "$TMPDIR/dotfiles-podman-agent.plist" "$HOME/Library/LaunchAgents/com.feipi.podman-services.plist"
# 只有目标与新模板完全相同时才加载；已有不同配置不会被误用
if cmp -s "$TMPDIR/dotfiles-podman-agent.plist" "$HOME/Library/LaunchAgents/com.feipi.podman-services.plist"; then
  # 加载后会按 RunAtLoad 启动服务；这是主动启用步骤
  launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.feipi.podman-services.plist"
fi
```

模板复用现有 `com.feipi.podman-services` Label，路径由渲染器从仓库位置和 HOME 推导，
不记录本机用户名。输出与错误分别保存在 `~/Library/Logs/`，失败不会无限重启。
不要在旧机直接替换或重复加载已有 LaunchAgent。

### Compose 和代码仓库的关系

`image:` 使用预构建镜像，通常只需 Compose、少量挂载配置和本机密钥；无需克隆上游应用源码。
`build:` 才需要 Dockerfile 和构建上下文；上下文可以来自独立代码仓库或 Git URL，
此时保存仓库地址、固定版本和准备命令，不把整个上游仓库复制进 Dotfiles。
参见 [Compose 服务定义](https://docs.docker.com/reference/compose-file/services/) 和
[构建上下文](https://docs.docker.com/reference/compose-file/build/)。

当前四个容器对应的三份 Compose 都只声明镜像，没有 `build:`，文件合计约 7 KB。
Compose 与挂载配置目前归 `feipi-agent-kit/tools/` 中的 `gateway/litellm`、`search/searxng`、
`crawl/crawl4ai` 管理，本仓库只保存机器启动入口，不复制它们或上游源码。
新 Mac 需要取回这些项目配置；PostgreSQL 数据和认证材料需要另行恢复，启动脚本不能代替数据备份。

插件锁文件与分支对齐、其他运行时整理不纳入本轮，避免在配置迁移时隐式升级工具。
