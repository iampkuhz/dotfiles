# Qwen Code 配置管理说明

## 目标
- 用仓库管理可复用的 `~/.qwen/` 配置，避免把机器状态或密钥入库。
- 通过 GNU Stow 安装：`stow -v qwen`（目标目录由 `.stowrc` 设为 `~`）。

## 已纳入的配置
- `/Users/zhehan/Documents/tools/dotfiles/qwen/.qwen/settings.json`
  - 说明：主配置入口，包含模型提供方与默认模型。
  - 关键字段语义：
    - `modelProviders`: 定义可用模型列表与接入地址。
    - `envKey`: 指定从环境变量读取密钥的变量名。
    - `generationConfig`: 模型生成参数（如 `contextWindowSize`）。
- `/Users/zhehan/Documents/tools/dotfiles/qwen/.qwen/output-language.md`
  - 说明：控制助手输出语言的偏好规则。

## 明确不纳入的内容
- `~/.qwen/skills/`：按你的要求不纳入仓库管理。
- `~/.qwen/installation_id`、`~/.qwen/debug/`、`~/.qwen/tmp/`、`~/.qwen/projects/`：运行态或机器相关文件。

## 密钥与本地覆盖
- 仓库中的 `settings.json` 不包含 `env` 字段，避免泄露密钥。
- 请在本机环境变量中提供密钥，例如（示例）：

```bash
export BAILIAN_CODING_PLAN_API_KEY="YOUR_KEY"
```

## 变更说明
- 如果你需要新增/调整模型，请修改 `settings.json` 并同步到仓库。
- 若需要本机特有的私密配置，请放在 shell 环境变量中，不要提交到仓库。
