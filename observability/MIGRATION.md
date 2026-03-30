# 从 Langfuse 全栈迁移到 LiteLLM 轻量代理

> **迁移目标**：降低本地资源占用，简化运维复杂度
> **预计时间**：30 分钟
> **风险等级**：低（可并行运行，逐步切换）

---

## 1. 迁移背景

### 1.1 为什么要迁移？

| 考量 | Langfuse 全栈 | LiteLLM 轻量代理 |
|------|---------------|------------------|
| 容器数量 | 6+ | 1 |
| 本地内存 | 2GB+ | < 500MB |
| 启动时间 | 2-5 分钟 | < 30 秒 |
| 数据持久化 | 本地管理 | 云端平台（可选） |
| 运维复杂度 | 高（多容器依赖） | 低（单容器） |

### 1.2 迁移后变化

**不再运行的组件：**
- Langfuse Web / Worker
- PostgreSQL（Langfuse 专用）
- ClickHouse
- Redis
- MinIO

**继续运行的组件：**
- LiteLLM Proxy（端口 4000）

**数据影响：**
- 历史 Trace 数据保留在 Langfuse 容器中（如需导出请提前备份）
- 新数据可选择发送到云端观测平台（Braintrust / Arize AX）

---

## 2. 迁移步骤

### 2.1 准备阶段

#### Step 1: 确认当前状态

```bash
# 检查是否正在运行 Langfuse 全栈
podman ps | grep -E "langfuse|clickhouse|redis|minio"

# 检查是否已运行 LiteLLM
podman ps | grep litellm
```

#### Step 2: 备份重要数据（如需要）

```bash
# 导出 Langfuse PostgreSQL 数据（可选）
podman exec langfuse-postgres pg_dump -U postgres postgres > langfuse_backup.sql

# 备份现有配置
cp -r observability/langfuse observability/langfuse.backup
```

---

### 2.2 配置阶段

#### Step 3: 准备 LiteLLM 环境变量

```bash
# 复制模板
cp observability/litellm/.env.example ~/.env.litellm

# 编辑 ~/.env.litellm，填入真实值
# 必需变量：
# - LITELLM_MASTER_KEY（生成随机 token）
# - BAILIAN_CODING_PLAN_API_KEY
# - BAILIAN_CODING_PLAN_OPENAI_BASE_URL
# - BAILIAN_CODING_PLAN_ANTHROPIC_BASE_URL
```

#### Step 4: 检查 config.yaml

```bash
# 查看当前配置
cat observability/litellm/config.yaml

# 如需接 Langfuse，确保配置了回调
# 如不接，可注释掉 success_callback / failure_callback
```

---

### 2.3 切换阶段

#### Step 5: 启动 LiteLLM

```bash
cd observability/litellm
podman compose up -d

# 验证启动
podman compose ps
curl http://localhost:4000/health
```

#### Step 6: 更新客户端配置

```bash
# ~/.openclaw/.env
OPENCLAW_BASE_URL=http://127.0.0.1:4000/v1
OPENCLAW_API_KEY=<你的 LITELLM_MASTER_KEY>
OPENCLAW_MODEL_ID=qwen3.5-plus
```

#### Step 7: 测试客户端

```bash
# 重启 OpenClaw 或重新加载配置
# 发送测试请求，确认通过 LiteLLM 转发成功
```

---

### 2.4 清理阶段

#### Step 8: 停止 Langfuse 全栈

```bash
# 确认客户端已成功切换到 LiteLLM 后
cd observability/langfuse
podman compose down

# 验证已停止
podman ps | grep langfuse  # 应无输出
```

#### Step 9: （可选）删除 Langfuse 数据卷

```bash
# ⚠️ 警告：此操作会永久删除所有历史数据
# 仅在不需保留历史 Trace 时执行

cd observability/langfuse
podman compose down -v
```

---

## 3. 回滚方案

如需回滚到 Langfuse 全栈方案：

```bash
# 1. 停止 LiteLLM
cd observability/litellm
podman compose down

# 2. 启动 Langfuse
cd observability/langfuse
podman compose up -d

# 3. 恢复客户端配置
# OPENCLAW_BASE_URL 改回直连上游或使用其他网关
```

---

## 4. 迁移后验证

### 4.1 基础验证清单

```bash
# ✓ LiteLLM 可启动
podman compose ps -C litellm

# ✓ 4000 端口可访问
curl http://localhost:4000/health

# ✓ /v1/models 返回模型列表
curl -s http://localhost:4000/v1/models | jq '.data | length'

# ✓ /v1/chat/completions 返回有效响应
curl -s http://localhost:4000/v1/chat/completions \
  -X POST \
  -H "Authorization: Bearer ${LITELLM_MASTER_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"model":"qwen3.5-plus","messages":[{"role":"user","content":"Hi"}]}' | jq .

# ✓ 无 Langfuse 容器常驻
podman ps | grep langfuse  # 应无输出
```

### 4.2 性能验证

```bash
# 检查内存占用
podman stats litellm-proxy --no-stream

# 预期：空闲时 < 500MB，有负载时 < 1GB
```

---

## 5. 常见问题

### Q1: 迁移后没有观测数据了怎么办？

LiteLLM 轻量代理默认不强制接观测平台。如需观测数据：

1. **方案 A**：配置 Langfuse 回调（保留部分观测能力）
2. **方案 B**：配置 OTel，发送到 Braintrust / Arize AX

### Q2: 还能用 Langfuse 吗？

可以。Langfuse 方案已归档，但并未删除。如需临时使用：

```bash
cd observability/langfuse
podman compose up -d
```

但不推荐作为默认方案，因为资源占用过高。

### Q3: 迁移后请求失败

排查顺序：

1. 检查 `LITELLM_MASTER_KEY` 是否与客户端配置一致
2. 检查上游 API Key 和端点是否正确
3. 查看 LiteLLM 日志：`podman compose logs litellm`
4. 检查网络/代理配置

---

## 6. 迁移检查清单

请在迁移完成后勾选以下项目：

### 配置阶段
- [ ] 已复制 `.env.example` 并填入真实值
- [ ] 已检查 `config.yaml` 配置
- [ ] 已生成 `LITELLM_MASTER_KEY`

### 启动阶段
- [ ] LiteLLM 容器启动成功
- [ ] 健康检查通过（4000 端口可访问）
- [ ] `/v1/models` 返回模型列表

### 切换阶段
- [ ] 客户端配置已更新指向 LiteLLM
- [ ] 测试请求成功返回
- [ ] 无报错或异常

### 清理阶段
- [ ] Langfuse 全栈已停止
- [ ] 确认无 langfuse 容器常驻
- [ ] （可选）历史数据已备份或删除

### 验收阶段
- [ ] 内存占用达标（< 500MB）
- [ ] 客户端功能正常
- [ ] 团队已知晓迁移完成

---

## 7. 后续扩展

### 7.1 接入 Braintrust

```bash
# 配置 OTel 环境变量
export OTEL_EXPORTER_OTLP_ENDPOINT=https://otlp.braintrust.dev
export OTEL_EXPORTER_OTLP_HEADERS=Authorization=Bearer <your-key>
export USE_OTEL_LITELLM_REQUEST_SPAN=true

# 重启 LiteLLM
podman compose restart
```

### 7.2 接入 Arize AX

```bash
# 配置 Arize OTel 端点
export OTEL_EXPORTER_OTLP_ENDPOINT=https://otlp.ax.arize.com
export OTEL_EXPORTER_OTLP_HEADERS=Organization-Id=<org-id>,Api-Key=<api-key>
export USE_OTEL_LITELLM_REQUEST_SPAN=true

# 重启 LiteLLM
podman compose restart
```

### 7.3 客户端透传 metadata

确保客户端请求中包含以下字段，便于观测平台关联：

```python
{
    "metadata": {
        "scene": "code_completion",
        "use_case": "unit_test",
        "client_name": "openclaw",
        "trace_id": "unique-trace-id",
        "session_id": "session-id"
    }
}
```

---

## 8. 参考资料

- [ACCEPTANCE.md](./ACCEPTANCE.md) - 验收与完成定义
- [litellm/README.md](./litellm/README.md) - LiteLLM 使用指南
- [langfuse/README.md](./langfuse/README.md) - Langfuse 归档方案
