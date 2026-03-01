# LiteLLM（远程模型 + Podman）

## 前置准备（只需一次）
你的 zsh 需要先把 `~/.env` 加载到当前环境（你已配置自动加载）。  
`~/.env` 里至少要有这 6 个变量：
- `LITELLM_MASTER_KEY`
- `LANGFUSE_PUBLIC_KEY`
- `LANGFUSE_SECRET_KEY`
- `REMOTE_MODEL_ID`
- `REMOTE_UPSTREAM_BASE_URL`
- `REMOTE_UPSTREAM_API_KEY`

变量模板见：`/Users/zhehan/Documents/tools/dotfiles/observability/litellm/.env.example`

## 直接执行命令
```bash
cd /Users/zhehan/Documents/tools/dotfiles/observability/litellm

# 拉取镜像
podman pull docker.litellm.ai/berriai/litellm:main-latest

# 启动（固定 remote）
LITELLM_CONFIG_FILE=./config.remote.yaml podman compose up -d
```

## 查看状态
```bash
cd /Users/zhehan/Documents/tools/dotfiles/observability/litellm
podman compose ps
podman compose logs -f litellm
```

## 停止
```bash
cd /Users/zhehan/Documents/tools/dotfiles/observability/litellm
podman compose down
```

## 对接 OpenClaw
在 `~/.openclaw/.env` 设置：
```bash
OPENCLAW_BASE_URL=http://127.0.0.1:4000/v1
OPENCLAW_API_KEY=<与 LITELLM_MASTER_KEY 相同>
OPENCLAW_MODEL_ID=openclaw-default
OPENCLAW_MODEL_NAME=OpenClaw Default (LiteLLM)
```

## YAML 是否支持环境变量
支持。LiteLLM YAML 支持 `os.environ/变量名`，`config.remote.yaml` 已使用该写法。
