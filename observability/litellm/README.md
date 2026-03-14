# LiteLLM（远程模型 + Podman）

## 前置准备（只需一次）
你的 zsh 需要先把 `~/.env` 加载到当前环境（你已配置自动加载）。  
`~/.env` 里至少要有这 7 个变量：
- `LITELLM_MASTER_KEY`
- `LANGFUSE_PUBLIC_KEY`
- `LANGFUSE_SECRET_KEY`
- `LITELLM_UPSTREAM_MODEL`
- `LITELLM_UPSTREAM_BASE_URL`
- `LITELLM_UPSTREAM_API_KEY`
- `POSTGRES_PASSWORD`

`POSTGRES_PASSWORD` 必须和 Langfuse 那边启动 PostgreSQL 时使用的密码一致。
这是因为 LiteLLM 会直接连接 `host.containers.internal:5433` 上暴露出来的 Langfuse Postgres。
但 LiteLLM 会使用独立的 `litellm` 数据库，不和 Langfuse 的 `postgres` 数据库混用。

变量模板见：`/Users/zhehan/Documents/tools/dotfiles/observability/litellm/.env.example`

## 直接执行命令
```bash
cd /Users/zhehan/Documents/tools/dotfiles/observability/litellm

# 拉取镜像
podman pull docker.litellm.ai/berriai/litellm:main-latest

# 启动（当前 shell 需要已经带上 ~/.env 中的变量）
podman compose up -d
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
