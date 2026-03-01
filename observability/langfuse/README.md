# Langfuse（极简版）

## 1. 目标
- 在本机启动 Langfuse 全套依赖：`web + worker + postgres + clickhouse + redis + minio`
- 给 LiteLLM 提供本地观测后端：`http://localhost:3000`

## 3. 预拉取镜像
```bash
docker pull docker.io/langfuse/langfuse:3
docker pull docker.io/langfuse/langfuse-worker:3
docker pull docker.io/postgres:17
docker pull docker.io/clickhouse/clickhouse-server
docker pull docker.io/redis:7
docker pull cgr.dev/chainguard/minio
```

## 4. 初始化
```bash
cd /Users/zhehan/Documents/tools/dotfiles/observability/langfuse
cp .env.example .env
```

## 5. 只需要填 7 个变量
编辑 `.env`：
- `LANGFUSE_NEXTAUTH_SECRET`
- `LANGFUSE_SALT`
- `LANGFUSE_ENCRYPTION_KEY`
- `POSTGRES_PASSWORD`
- `CLICKHOUSE_PASSWORD`
- `REDIS_PASSWORD`
- `MINIO_PASSWORD`

密钥生成命令：
```bash
openssl rand -base64 32   # 生成 NEXTAUTH_SECRET 或 SALT
openssl rand -hex 32      # 生成 ENCRYPTION_KEY
```

## 6. 启动
```bash
cd /Users/zhehan/Documents/tools/dotfiles/observability/langfuse
docker compose up -d
```

## 7. 验证
查看状态：
```bash
docker compose ps
```

看关键日志：
```bash
docker compose logs -f langfuse-web langfuse-worker
```

打开控制台：
- `http://localhost:3000`

## 8. 给 LiteLLM 用的密钥
1. 登录 `http://localhost:3000`
2. 进入目标 Project 的 Settings
3. 复制 `Public Key` 和 `Secret Key`
4. 写到 LiteLLM 的 `.env`：
```bash
LANGFUSE_PUBLIC_KEY=pk-lf-xxxx
LANGFUSE_SECRET_KEY=sk-lf-xxxx
```

## 9. 常用命令
```bash
# 停止（保留数据）
cd /Users/zhehan/Documents/tools/dotfiles/observability/langfuse
docker compose down

# 清空全部数据并重建（危险）
docker compose down -v

# 重启
docker compose restart
```
