# LiteLLM 轻量代理

> **定位**：本地 AI 模型网关，提供统一的 OpenAI 兼容接口
> **状态**：✅ 当前唯一默认方案
> **特点**：轻量、低内存（< 500MB）、单容器、本地可运行

---

## 快速开始

### 1. 准备环境变量

```bash
# 复制模板
cp observability/litellm/.env.example ~/.env.litellm

# 编辑 ~/.env.litellm，填入真实值
# 至少需要配置：
# - LITELLM_MASTER_KEY（生成随机 token）
# - BAILIAN_CODING_PLAN_API_KEY
```

### 2. 启动服务

```bash
cd observability/litellm
podman compose up -d
```

### 3. 验证启动

```bash
# 检查容器状态（应显示 healthy）
podman compose ps

# 检查健康端点
curl -s http://localhost:4000/health

# 检查模型列表
curl -s http://localhost:4000/v1/models \
  -H "Authorization: Bearer ${LITELLM_MASTER_KEY}" | jq .
```

### 4. 测试对话

```bash
curl -s http://localhost:4000/v1/chat/completions \
  -X POST \
  -H "Authorization: Bearer ${LITELLM_MASTER_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen3.5-plus",
    "messages": [{"role": "user", "content": "Hello"}],
    "stream": false
  }' | jq .
```

---

## 配置说明

### 环境变量

| 变量名 | 用途 | 是否必需 |
|--------|------|----------|
| `LITELLM_MASTER_KEY` | LiteLLM 访问密钥 | 必需 |
| `BAILIAN_CODING_PLAN_API_KEY` | 百炼 API 密钥 | 必需 |
| `BAILIAN_CODING_PLAN_OPENAI_BASE_URL` | 百炼 OpenAI 兼容端点 | 必需 |
| `BAILIAN_CODING_PLAN_ANTHROPIC_BASE_URL` | 百炼 Anthropic 兼容端点 | 必需 |
| `LITELLM_OPENAI_QWEN_MODEL` | OpenAI 协议模型名 | 必需 |
| `LITELLM_ANTHROPIC_QWEN_MODEL` | Anthropic 协议模型名 | 必需 |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OTel 端点（接 Braintrust/Arize） | 可选 |
| `OTEL_EXPORTER_OTLP_HEADERS` | OTel 请求头 | 可选 |
| `USE_OTEL_LITELLM_REQUEST_SPAN` | 是否启用 Request Span | 可选 |

### config.yaml 结构

```yaml
model_list:
  - model_name: <逻辑名>
    litellm_params:
      model: <provider/model-id>
      api_base: <端点>
      api_key: <密钥>

litellm_settings:
  # 当前不配置本地观测回调
  # 未来通过 OTel 接入云端平台

general_settings:
  master_key: <访问密钥>
```

---

## 常用命令

```bash
# 启动
cd observability/litellm
podman compose up -d

# 查看状态
podman compose ps

# 查看日志
podman compose logs -f litellm

# 重启（修改 config.yaml 后）
podman compose restart litellm

# 停止
podman compose down
```

---

## 客户端接入

### OpenClaw

在 `~/.openclaw/.env` 配置：

```bash
OPENCLAW_BASE_URL=http://127.0.0.1:4000/v1
OPENCLAW_API_KEY=<与 LITELLM_MASTER_KEY 相同>
OPENCLAW_MODEL_ID=qwen3.5-plus
```

### 其他客户端

使用标准 OpenAI SDK 格式：

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://127.0.0.1:4000/v1",
    api_key="你的 LITELLM_MASTER_KEY"
)

response = client.chat.completions.create(
    model="qwen3.5-plus",
    messages=[{"role": "user", "content": "Hello"}]
)
```

### 透传 metadata（用于观测平台）

```python
response = client.chat.completions.create(
    model="qwen3.5-plus",
    messages=[{"role": "user", "content": "Test"}],
    metadata={
        "scene": "code_completion",
        "use_case": "unit_test",
        "client_name": "openclaw",
        "trace_id": "trace-001",
        "session_id": "session-001"
    }
)
```

**建议透传字段：**
- `scene` - 使用场景
- `use_case` - 具体用例
- `client_name` - 客户端标识
- `trace_id` - 链路追踪 ID
- `session_id` - 会话 ID

---

## 接入观测平台

### 当前配置

当前**不默认依赖任何本地观测组件**。LiteLLM 独立运行，无需 Langfuse、ClickHouse、Redis 等。

### 未来接入 Braintrust / Arize AX

只需配置 OTel 环境变量：

```bash
export OTEL_EXPORTER_OTLP_ENDPOINT=https://otlp.braintrust.dev
export OTEL_EXPORTER_OTLP_HEADERS=Authorization=Bearer your-key
export USE_OTEL_LITELLM_REQUEST_SPAN=true
```

然后重启 LiteLLM：

```bash
podman compose restart
```

**为什么建议启用 `USE_OTEL_LITELLM_REQUEST_SPAN=true`？**

- Request Span 会记录完整的请求/响应生命周期
- 包含延迟、token 消耗、错误信息等关键指标
- 便于在观测平台中追踪端到端链路

---

## 架构说明

### 当前架构

```
┌──────────────┐     ┌──────────────┐     ┌─────────────────┐
│   客户端      │ ──► │  LiteLLM     │ ──► │  上游模型 API     │
│ (OpenClaw)   │     │  (端口 4000)  │     │ (百炼 / 其他)     │
└──────────────┘     └──────────────┘     └─────────────────┘
                              │
                              │ (可选 OTel)
                              ▼
                    ┌─────────────────┐
                    │ Braintrust /    │
                    │ Arize AX        │
                    └─────────────────┘
```

### 轻量化目标

| 指标 | 目标值 | 验证命令 |
|------|--------|----------|
| 容器数量 | 1 | `podman ps --filter name=litellm` |
| 内存占用 | < 500MB（空闲） | `podman stats litellm-proxy` |
| 启动时间 | < 30 秒 | - |

---

## 故障排查

详见 [../ACCEPTANCE.md](../ACCEPTANCE.md)

**快速诊断命令：**

```bash
# 1. 检查容器状态
podman compose ps

# 2. 查看日志
podman compose logs --tail 50 litellm

# 3. 检查环境变量
podman inspect litellm-proxy | jq '.[0].Config.Env'

# 4. 验证健康端点
curl -s http://localhost:4000/health

# 5. 检查端口监听
lsof -i :4000
```

---

## 完成定义

满足以下**全部条件**时，可判定 LiteLLM 已可使用：

1. ✅ `podman compose up -d` 无错误，容器状态为 Up
2. ✅ `http://localhost:4000` 可访问，health 端点返回 200
3. ✅ `/v1/chat/completions` 返回有效响应
4. ✅ 文档完整（README + .env.example + config.yaml）
5. ✅ 仅运行 1 个 LiteLLM 容器，无 Langfuse 等重型依赖
6. ✅ OTel 配置位已预留，可无缝接入 Braintrust/Arize
