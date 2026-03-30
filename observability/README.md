# Observability 可观测性架构

> **当前默认方案：LiteLLM 轻量代理**
>
> 本目录提供 AI 应用的可观测性基础设施。**默认推荐使用 LiteLLM 轻量代理方案**，本地仅运行一个 LiteLLM 容器，观测数据可选择性发送到云端平台（Braintrust / Arize AX）。
>
> **Langfuse 已删除**：自 2026-03-29 起，langfuse 目录及相关配置已彻底移除，不再作为可选方案。

---

## 快速开始

### 启动 LiteLLM 轻量代理

```bash
# 1. 准备环境变量
cp observability/litellm/.env.example ~/.env.litellm
# 编辑 ~/.env.litellm 填入真实 API Key

# 2. 启动服务
cd observability/litellm
podman compose up -d

# 3. 验证
curl http://localhost:4000/health
```

### 客户端接入

```bash
# ~/.openclaw/.env
OPENCLAW_BASE_URL=http://127.0.0.1:4000/v1
OPENCLAW_API_KEY=<你的 LITELLM_MASTER_KEY>
OPENCLAW_MODEL_ID=qwen3.5-plus
```

---

## 目录结构

```
observability/
├── README.md              # 本文档
├── ACCEPTANCE.md          # 验收与完成定义（DoD）
├── MIGRATION.md           # 从 Langfuse 迁移指南（历史参考）
└── litellm/
    ├── README.md          # LiteLLM 使用指南
    ├── docker-compose.yml # 容器编排配置
    ├── config.yaml        # LiteLLM 路由与回调配置
    └── .env.example       # 环境变量模板
```

---

## 架构说明

### 当前架构（LiteLLM 轻量代理）

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

**核心特性：**
- 本地仅运行一个 LiteLLM 容器
- 不强制依赖本地观测数据库
- 支持通过 OTel 发送到云端平台
- 客户端 metadata 可透传到观测平台

### 方案定位

| 考量 | 当前方案 |
|------|----------|
| 本地容器数 | 1 |
| 本地内存占用 | < 500MB |
| 启动时间 | < 30s |
| 运维成本 | 低（单容器） |
| 扩展性 | OTel 直送云端 |

**适用场景：**
- ✅ 本地开发调试
- ✅ 已有云端观测平台（Braintrust / Arize）
- ✅ 希望降低本地运维负担

---

## 未来扩展：接入 Braintrust / Arize AX

只需在环境变量中配置 OTel 端点：

```bash
OTEL_EXPORTER_OTLP_ENDPOINT=https://otlp.braintrust.dev
OTEL_EXPORTER_OTLP_HEADERS=Authorization=Bearer <your-key>
USE_OTEL_LITELLM_REQUEST_SPAN=true
```

LiteLLM 会自动开始输出标准 OTel traces，无需修改代码或重构目录结构。

---

## 验收与完成定义

完整的验收标准请见：[ACCEPTANCE.md](./ACCEPTANCE.md)

**最小验收命令链：**

```bash
# 启动并验证
cd observability/litellm && \
  podman compose up -d && \
  sleep 5 && \
  podman compose ps && \
  curl -s http://localhost:4000/health && \
  echo "✓ 验证通过"
```

**停止服务：**

```bash
cd observability/litellm
podman compose down
```

---

## 客户端透传字段建议

为方便观测平台关联数据，建议在请求中包含以下 metadata：

- `scene` - 使用场景（如：code_completion）
- `use_case` - 具体用例（如：unit_test）
- `client_name` - 客户端标识（如：openclaw）
- `trace_id` - 链路追踪 ID
- `session_id` - 会话 ID

示例：

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

---

## 历史说明

### Langfuse 已彻底删除

自 2026-03-29 起，langfuse 目录及相关配置已彻底移除。

**删除原因：**
- Langfuse 全栈（Postgres + ClickHouse + Redis + MinIO）内存占用过高（2GB+）
- 不适合本地开发环境常驻
- 观测数据可直送云端平台，无需本地中转

**历史参考：**
- 不再保留任何 langfuse 相关文件
- 如需了解历史架构，请查看 git 历史记录
