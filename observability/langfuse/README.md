# Langfuse

## 配置环境变量
你的 zsh 需要先把 `~/.env` 加载到当前环境（你已配置自动加载）。
Langfuse 的 compose 配置直接使用当前 shell 中已有的环境变量，不额外依赖当前目录下的 `.env` 文件。

`~/.env` 里只需要填写这 7 个变量：

- `LANGFUSE_NEXTAUTH_SECRET`
- `LANGFUSE_SALT`
- `LANGFUSE_ENCRYPTION_KEY`
- `POSTGRES_PASSWORD`
- `CLICKHOUSE_PASSWORD`
- `REDIS_PASSWORD`
- `MINIO_PASSWORD`

可用下面的命令生成：

```bash
openssl rand -base64 32   # 用于 NEXTAUTH_SECRET 或 SALT
openssl rand -hex 32      # 用于 ENCRYPTION_KEY
```

## 启动
```bash
cd /Users/zhehan/Documents/tools/dotfiles/observability/langfuse
podman compose up -d
```

## 验证
查看状态：

```bash
podman compose ps
```

查看关键日志：

```bash
podman compose logs -f langfuse-web langfuse-worker
```

控制台地址：

- `http://localhost:3000`

## 获取 Langfuse 项目密钥
1. 登录 `http://localhost:3000`
2. 进入目标 Project 的 `Settings`
3. 复制 `Public Key` 和 `Secret Key`
4. 写入你的应用配置：

```bash
LANGFUSE_PUBLIC_KEY=pk-lf-xxxx
LANGFUSE_SECRET_KEY=sk-lf-xxxx
```

## 常用命令
```bash
# 停止并保留数据
podman compose down

# 清空全部数据后重建（危险）
podman compose down -v

# 重启服务
podman compose restart
```
