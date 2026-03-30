# LiteLLM 轻量代理验收文档

> 本文档定义「LiteLLM 轻量代理改造」的完成标准与验收步骤。
> 目标：确保改造后的架构可启动、可调用、可扩展，并明确「完成定义」。

---

## 1. 完成定义（Definition of Done, DoD）

### 1.1 架构层

| 编号 | 验收项 | 验证方式 | 状态 |
|------|--------|----------|------|
| A1 | 本地默认常驻方案只剩 LiteLLM Proxy | `podman ps` 只显示 `litellm-proxy` 容器 | ☐ |
| A2 | 本地不再默认依赖 Langfuse / ClickHouse / Redis / MinIO / Postgres | `podman ps -a` 不应看到 langfuse 全家桶常驻 | ☐ |
| A3 | Langfuse 目录已被清晰标注为归档/停用/历史方案 | `observability/langfuse/README.md` 顶部有明确归档标识 | ☐ |
| A4 | 当前默认架构已明确支持未来接入 Braintrust / Arize AX | 文档中说明 OTel 扩展路径，配置未写死单一平台 | ☐ |

**架构决策说明：**

- **为什么去掉本地 Langfuse 常驻？**
  - Langfuse 全栈（Postgres + ClickHouse + Redis + MinIO）内存占用过高，不适合本地开发环境常驻
  - 观测数据可直送云端平台（Braintrust / Arize AX），无需本地中转
  - LiteLLM 本身支持 OTel 输出，可直接对接外部观测平台

- **未来扩展性保证：**
  - LiteLLM 配置采用环境变量注入，不硬编码任何观测平台端点
  - OTel 相关环境变量已预留，启用后可直接输出标准 trace/span
  - 客户端 metadata / tags 透传机制已设计，支持 scene / trace_id / session_id 等字段

---

### 1.2 运行层

| 编号 | 验收项 | 验证方式 | 状态 |
|------|--------|----------|------|
| R1 | `observability/litellm/docker-compose.yml` 可直接启动 | `podman compose up -d` 无错误 | ☐ |
| R2 | LiteLLM 容器健康检查通过 | `podman compose ps` 显示 `healthy` 或 `Up` | ☐ |
| R3 | 4000 端口可访问 | `curl -s http://localhost:4000/health` 返回 200 | ☐ |
| R4 | 基础 chat/completions 请求可成功返回 | `/v1/chat/completions` 返回非空响应 | ☐ |
| R5 | 不配置 OTel 时，系统仍可正常工作 | 不填 OTel 环境变量，LiteLLM 正常启动 | ☐ |
| R6 | 配置 OTel 环境变量后，不阻碍 LiteLLM 启动 | 填入 OTel 端点，服务仍正常启动 | ☐ |

---

### 1.3 配置层

| 编号 | 验收项 | 验证方式 | 状态 |
|------|--------|----------|------|
| C1 | `.env.example` 足够指导用户复制为 `.env` | 文件包含所有必需变量，含注释说明 | ☐ |
| C2 | `config.yaml` 结构清晰，支持后续增加模型和接入观测平台 | YAML 分模块组织，模型/回调/通用设置分离 | ☐ |
| C3 | README 足以指导使用者独立完成启动、验证、停止 | 新人按文档可独立完成全流程 | ☐ |

---

### 1.4 扩展层

| 编号 | 验收项 | 验证方式 | 状态 |
|------|--------|----------|------|
| E1 | 文档明确说明未来如何接 Braintrust / Arize | 有专门章节说明 OTel 配置步骤 | ☐ |
| E2 | 文档明确说明客户端侧需要透传的字段 | README 列出 scene / use_case / client_name / trace_id / session_id | ☐ |
| E3 | 文档说明为什么建议启用 `USE_OTEL_LITELLM_REQUEST_SPAN=true` | 有专门说明 OTel span 的价值 | ☐ |
| E4 | 当前架构不需要大改即可继续接入外部分析平台 | 无需修改目录结构，仅需补充环境变量 | ☐ |

---

## 2. 验收步骤（Step-by-step Acceptance Checklist）

### 2.1 A. 配置文件检查

#### A.1 必须存在的文件

```bash
# 检查核心文件是否存在
ls -la /Users/zhehan/Documents/tools/dotfiles/observability/litellm/
```

**预期输出中必须包含：**
- `docker-compose.yml` — 容器编排配置
- `config.yaml` — LiteLLM 路由与回调配置
- `.env.example` — 环境变量模板

#### A.2 环境变量模板检查

```bash
cat /Users/zhehan/Documents/tools/dotfiles/observability/litellm/.env.example
```

**必须包含的占位变量：**

| 变量名 | 用途 | 是否必需 | 可留空条件 |
|--------|------|----------|------------|
| `LITELLM_MASTER_KEY` | LiteLLM 网关访问 token | 必需 | 否 |
| `BAILIAN_CODING_PLAN_API_KEY` | 百炼 API 密钥 | 必需 | 否 |
| `BAILIAN_CODING_PLAN_OPENAI_BASE_URL` | 百炼 OpenAI 兼容端点 | 必需 | 否 |
| `BAILIAN_CODING_PLAN_ANTHROPIC_BASE_URL` | 百炼 Anthropic 兼容端点 | 必需 | 否 |
| `LITELLM_OPENAI_QWEN_MODEL` | OpenAI 协议模型名 | 必需 | 否 |
| `LITELLM_ANTHROPIC_QWEN_MODEL` | Anthropic 协议模型名 | 必需 | 否 |
| `LANGFUSE_PUBLIC_KEY` | Langfuse 公钥 | 可选 | 不接 Langfuse 时可留空 |
| `LANGFUSE_SECRET_KEY` | Langfuse 私钥 | 可选 | 不接 Langfuse 时可留空 |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OTel 端点 | 可选 | 不接 OTel 时可留空 |
| `USE_OTEL_LITELLM_REQUEST_SPAN` | 是否启用 Request Span | 可选 | 默认 `false` |

#### A.3 配置文件检查

```bash
# 检查 config.yaml 是否有效 YAML
python3 -c "import yaml; yaml.safe_load(open('observability/litellm/config.yaml'))"
```

**检查点：**
- 无 YAML 语法错误
- `model_list` 至少有一个有效模型
- `litellm_settings` 中的回调配置正确

---

### 2.2 B. 启动检查

#### B.1 准备环境变量

```bash
# 1. 复制模板
cp observability/litellm/.env.example ~/.env.litellm

# 2. 编辑 ~/.env.litellm，填入真实值
# 或使用以下命令生成随机 token
openssl rand -hex 16  # 作为 LITELLM_MASTER_KEY
```

#### B.2 启动命令

```bash
# 方式1：使用 podman（推荐，当前仓库默认）
cd /Users/zhehan/Documents/tools/dotfiles/observability/litellm
podman compose up -d

# 方式2：使用 docker compose
docker compose up -d
```

#### B.3 启动后检查

```bash
# 检查容器状态
podman compose ps

# 预期输出示例：
# NAME               STATUS
# litellm-proxy      Up (healthy)
```

**成功标志：**
- 容器状态为 `Up` 或 `healthy`
- 没有容器反复重启（RESTARTS 为 0）

#### B.4 日志检查

```bash
# 查看启动日志
podman compose logs litellm

# 持续跟踪日志
podman compose logs -f litellm
```

**预期看到的关键日志：**
```
LiteLLM: Running on http://0.0.0.0:4000
Prisma db push completed
Server running successfully
```

**失败标志：**
- `model is None` — 检查环境变量是否传入
- `Connection refused` — 检查 `host.containers.internal` 是否可达
- `502` 错误 — 检查代理配置是否污染

#### B.5 健康检查

```bash
# 健康端点检查
curl -s http://localhost:4000/health

# 预期返回 200 OK，包含 JSON 响应
```

---

### 2.3 C. 接口检查

#### C.1 验证 `/v1/models`

```bash
curl -s http://localhost:4000/v1/models \
  -H "Authorization: Bearer ${LITELLM_MASTER_KEY}" \
  | jq .
```

**成功标志：**
- 返回 200 OK
- `data` 数组中包含配置的模型列表
- 每个模型有 `id`、`object`、`created` 字段

**失败排查：**
| 错误 | 优先检查 |
|------|----------|
| 401 Unauthorized | `LITELLM_MASTER_KEY` 是否正确 |
| 空列表 | `config.yaml` 中 `model_list` 配置 |
| 500 错误 | 容器日志，检查环境变量 |

#### C.2 验证 `/v1/chat/completions`

```bash
curl -s http://localhost:4000/v1/chat/completions \
  -X POST \
  -H "Authorization: Bearer ${LITELLM_MASTER_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen3.5-plus",
    "messages": [
      {"role": "user", "content": "Hello"}
    ],
    "stream": false
  }' | jq .
```

**成功标志：**
- 返回 200 OK
- 响应包含 `choices` 数组
- `choices[0].message.content` 非空

**失败排查：**
| 错误 | 优先检查 |
|------|----------|
| 401 | API Key 错误 |
| 404 model not found | 模型名是否与 config.yaml 一致 |
| 500 upstream error | 检查上游 API 端点是否可达 |
| timeout | 检查网络/代理配置 |

#### C.3 验证 metadata 透传（为 Braintrust / Arize 准备）

```bash
curl -s http://localhost:4000/v1/chat/completions \
  -X POST \
  -H "Authorization: Bearer ${LITELLM_MASTER_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen3.5-plus",
    "messages": [
      {"role": "user", "content": "Test trace"}
    ],
    "metadata": {
      "scene": "code_completion",
      "use_case": "unit_test",
      "client_name": "openclaw",
      "trace_id": "test-trace-001",
      "session_id": "test-session-001"
    },
    "stream": false
  }' | jq .
```

**成功标志：**
- 请求成功返回
- LiteLLM 日志中能看到 metadata 被接收
- 若配置了 OTel，trace_id 应出现在 span 中

---

### 2.4 D. 低内存目标检查

#### D.1 轻量化达标验收

```bash
# 检查当前运行容器
podman ps --format "{{.Names}}: {{.Status}}"

# 检查 LiteLLM 内存占用
podman stats litellm-proxy --no-stream
```

**达标标准：**

| 检查项 | 标准要求 | 验证命令 |
|--------|----------|----------|
| 容器数量 | 仅 1 个 `litellm-proxy` | `podman ps --filter name=litellm` |
| 无 Langfuse 常驻 | `podman ps` 不显示 `langfuse-*` | `podman ps --filter name=langfuse` |
| 内存占用 | LiteLLM < 500MB（空闲时） | `podman stats` |
| 无重型依赖 | 无 ClickHouse/Redis/MinIO 常驻 | `podman ps -a` |

**对比基准：**

| 方案 | 容器数 | 预估内存 |
|------|--------|----------|
| 迁移前（Langfuse 全栈 + LiteLLM） | 6+ | 2GB+ |
| 迁移后（仅 LiteLLM） | 1 | < 500MB |

**说明：** 当前目标不是把 LiteLLM 压到极限，而是去掉本地重型 observability 栈。

---

### 2.5 E. 未来接 Braintrust / Arize 的预验收

#### E.1 OTel 配置位检查

**检查 `.env.example` 是否包含：**

```bash
grep -E "^OTEL_" observability/litellm/.env.example
grep -E "^USE_OTEL_" observability/litellm/.env.example
```

**预期输出：**
```
OTEL_EXPORTER_OTLP_ENDPOINT=
OTEL_EXPORTER_OTLP_HEADERS=
USE_OTEL_LITELLM_REQUEST_SPAN=false
```

#### E.2 文档检查

**检查 README 是否说明：**
- [ ] Braintrust / Arize 优先走 OTel
- [ ] LiteLLM 配置没有写死到某个单一平台
- [ ] 客户端 metadata / tags / scene / trace_id 的要求已写入

#### E.3 架构灵活性检查

**验证点：**
- [ ] `config.yaml` 中的回调配置是可选的（不接 Langfuse 也能工作）
- [ ] 模型配置使用环境变量，方便切换不同 provider
- [ ] 没有硬编码的 enduser_id / team_id 限制

#### E.4 未来兼容性确认

```bash
# 模拟启用 OTel 的场景（不真正发送数据）
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export USE_OTEL_LITELLM_REQUEST_SPAN=true

# 重启 LiteLLM，观察是否正常启动
podman compose down
podman compose up -d

# 检查日志，确认 OTel 配置被读取但未报错
podman compose logs litellm | grep -i otel

# 清理测试配置
unset OTEL_EXPORTER_OTLP_ENDPOINT
unset USE_OTEL_LITELLM_REQUEST_SPAN
```

**成功标志：**
- LiteLLM 正常启动
- 没有因为 OTel 端点不可达而崩溃
- 日志显示 OTel 配置被识别

---

## 3. 常见失败场景与排查建议

### 3.1 LiteLLM 启动失败

**症状：** 容器启动后立即退出，或状态为 `Exited`

**排查步骤：**

```bash
# 1. 查看完整日志
podman compose logs --tail 100 litellm

# 2. 检查环境变量是否传入
podman inspect litellm-proxy | jq '.[0].Config.Env'

# 3. 检查 config.yaml 挂载
podman inspect litellm-proxy | jq '.[0].Mounts'
```

**常见原因：**
| 原因 | 解决方法 |
|------|----------|
| 环境变量缺失 | 确认 `~/.env` 或 compose environment 已传入 |
| config.yaml 格式错误 | 用 `python3 -c "import yaml; yaml.safe_load(...)"` 验证 |
| 数据库连接失败 | 检查 `DATABASE_URL` 是否正确，Postgres 是否可访问 |
| 端口冲突 | `lsof -i :4000` 检查端口占用 |

---

### 3.2 端口 4000 未监听

**症状：** `curl http://localhost:4000` 返回 `Connection refused`

**排查步骤：**

```bash
# 1. 检查容器是否运行
podman ps | grep litellm

# 2. 检查端口映射
podman port litellm-proxy

# 3. 检查端口占用
lsof -i :4000

# 4. 检查容器内日志
podman compose logs litellm | grep "Running on"
```

**常见原因：**
| 原因 | 解决方法 |
|------|----------|
| 容器未启动 | `podman compose up -d` |
| 端口被占用 | 修改 docker-compose.yml 端口映射 |
| LiteLLM 启动失败 | 查看日志，修复配置后重启 |

---

### 3.3 provider key 没填导致调用失败

**症状：** `/v1/chat/completions` 返回 401 或 500 错误

**排查步骤：**

```bash
# 1. 确认环境变量值
echo $BAILIAN_CODING_PLAN_API_KEY

# 2. 检查容器内是否读到变量
podman exec litellm-proxy env | grep BAILIAN

# 3. 测试上游端点直连
curl -s https://dashscope.aliyuncs.com/compatible-mode/v1/models \
  -H "Authorization: Bearer ${BAILIAN_CODING_PLAN_API_KEY}" | jq .
```

**解决方法：**
- 确认 API Key 未过期
- 确认端点 URL 正确
- 检查网络是否被代理拦截

---

### 3.4 config.yaml 格式错误

**症状：** LiteLLM 启动时报 YAML 解析错误

**验证方法：**

```bash
# 本地验证 YAML
python3 -c "import yaml; yaml.safe_load(open('observability/litellm/config.yaml'))"

# 或使用 yq
yq eval '.' observability/litellm/config.yaml
```

**常见错误：**
| 错误 | 原因 | 修复 |
|------|------|------|
| `found undefined alias` | YAML 别名引用不存在的锚点 | 检查 `*alias` 和 `&anchor` 配对 |
| `mapping values are not allowed here` | 缩进错误 | 检查 YAML 缩进是否为 2 空格 |
| `os.environ/xxx not found` | 环境变量不存在 | 确认变量已传入容器 |

---

### 3.5 OTel 环境变量配置了，但暂未接真实平台

**场景：** 配置了 OTel 端点，但本地没有运行 OTel Collector

**处理方法：**

```bash
# 方案 1：不配置 OTel，让 LiteLLM 正常工作
# 保持 .env 中 OTEL_* 为空即可

# 方案 2：配置 OTel 但允许端点不可达
# LiteLLM 会在 OTel 导出失败时降级，不会崩溃
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
# 即使没有 Collector，LiteLLM 仍能启动
```

**说明：** LiteLLM 的 OTel 导出是异步非阻塞的，端点不可达不会阻碍主流程。

---

### 3.6 启动后请求成功，但观测平台没有数据

**排查顺序：**

```
1. 检查 LiteLLM 是否配置了回调
   → 查看 config.yaml 中 litellm_settings.success_callback

2. 检查回调所需密钥是否正确
   → LANGFUSE_PUBLIC_KEY / LANGFUSE_SECRET_KEY

3. 检查观测平台是否可达
   → curl -v http://your-otel-endpoint/v1/traces

4. 检查 metadata 是否包含必要字段
   → trace_id / session_id 用于关联数据

5. 检查 LiteLLM 日志中是否有发送记录
   → podman compose logs | grep -i langfuse
```

**常见原因：**
| 原因 | 解决方法 |
|------|----------|
| 密钥错误 | 在 Langfuse Project Settings 重新生成 |
| 端点不可达 | 检查网络/防火墙/代理 |
| metadata 缺失 | 客户端请求中补充 trace_id 等字段 |

---

### 3.7 用户误启动 Langfuse 旧方案

**症状：** 同时运行了 Langfuse 和 LiteLLM，内存飙升

**识别方法：**

```bash
# 检查是否有 Langfuse 容器运行
podman ps | grep langfuse

# 检查是否有重型组件
podman ps | grep -E "clickhouse|redis|minio"
```

**处理方法：**

```bash
# 1. 停止 Langfuse
cd observability/langfuse
podman compose down

# 2. 确认只剩 LiteLLM
podman ps

# 3. 在 README 中明确标注 Langfuse 已归档
# → 见 observability/langfuse/README.md 顶部标识
```

**预防：** 在 `observability/README.md` 中明确标注默认方案为 LiteLLM。

---

## 4. 最终验收表（简洁版）

> 以下表格可直接作为人工验收单使用。验收人逐项检查后打勾。

### 4.1 核心功能验收

| 编号 | 验收项 | 验证方法 | 状态 |
|------|--------|----------|------|
| F1 | LiteLLM 可启动 | `podman compose up -d` 无错误 | ☐ |
| F2 | 4000 端口可访问 | `curl http://localhost:4000/health` | ☐ |
| F3 | `/v1/models` 正常 | `curl .../v1/models` 返回模型列表 | ☐ |
| F4 | `/v1/chat/completions` 正常 | 返回非空响应 | ☐ |
| F5 | 容器健康检查通过 | `podman compose ps` 显示 Up/healthy | ☐ |

### 4.2 文档验收

| 编号 | 验收项 | 验证方法 | 状态 |
|------|--------|----------|------|
| D1 | README 足够指导使用 | 新人按文档可独立完成全流程 | ☐ |
| D2 | .env.example 完整 | 包含所有必需变量 | ☐ |
| D3 | config.yaml 清晰 | 模块分离，注释完整 | ☐ |

### 4.3 架构验收

| 编号 | 验收项 | 验证方法 | 状态 |
|------|--------|----------|------|
| A1 | Langfuse 已归档 | `podman ps` 无 langfuse 容器 | ☐ |
| A2 | 轻量级达标 | 仅 1 个 LiteLLM 容器 | ☐ |
| A3 | OTel 配置位预留 | .env.example 含 OTEL_* 变量 | ☐ |
| A4 | 扩展性验证 | 接 Braintrust/Arize 无需重构目录 | ☐ |

### 4.4 验收签署

| 角色 | 姓名 | 日期 | 签名 |
|------|------|------|------|
| 开发负责人 | | | |
| 测试负责人 | | | |
| 运维负责人 | | | |

---

## 5. 最小验证命令链

### 5.1 最小启动验证

```bash
# 一键启动并验证（假设 ~/.env 已配置）
cd /Users/zhehan/Documents/tools/dotfiles/observability/litellm && \
  podman compose up -d && \
  sleep 5 && \
  podman compose ps && \
  curl -s http://localhost:4000/health && \
  echo "✓ LiteLLM 启动成功"
```

### 5.2 最小停止命令

```bash
cd /Users/zhehan/Documents/tools/dotfiles/observability/litellm
podman compose down
```

### 5.3 人工验收顺序建议

```
1. 检查文件完整性
   → ls observability/litellm/

2. 检查 .env.example 内容
   → cat observability/litellm/.env.example

3. 启动服务
   → podman compose up -d

4. 检查容器状态
   → podman compose ps

5. 检查健康端点
   → curl http://localhost:4000/health

6. 检查模型列表
   → curl .../v1/models

7. 检查对话接口
   → curl .../v1/chat/completions

8. 检查内存占用
   → podman stats litellm-proxy

9. 确认无 Langfuse 常驻
   → podman ps | grep langfuse

10. 停止服务
    → podman compose down
```

---

## 6. 判断「已经搞好、可使用」的最终标准

满足以下**全部条件**时，可判定本次改造已完成并可投入使用：

### 必要条件（必须全部满足）

1. ✅ **可启动**：`podman compose up -d` 无错误，容器状态为 Up
2. ✅ **可访问**：`http://localhost:4000` 可访问，health 端点返回 200
3. ✅ **可调用**：`/v1/chat/completions` 返回有效响应
4. ✅ **文档完整**：README + ACCEPTANCE + .env.example 齐全
5. ✅ **轻量达标**：仅运行 1 个 LiteLLM 容器，无 Langfuse 全家桶
6. ✅ **扩展就绪**：OTel 配置位已预留，接 Braintrust/Arize 无需重构

### 可选条件（建议满足）

- ✅ 配置了真实的 API Key 和端点
- ✅ 客户端已更新指向 LiteLLM 代理
- ✅ 团队已了解验收流程和排查方法

---

## 附录

### A. 环境变量完整清单

```bash
# ===== 必需变量 =====
LITELLM_MASTER_KEY=           # LiteLLM 访问密钥
BAILIAN_CODING_PLAN_API_KEY=  # 百炼 API 密钥
BAILIAN_CODING_PLAN_OPENAI_BASE_URL=     # 百炼 OpenAI 兼容端点
BAILIAN_CODING_PLAN_ANTHROPIC_BASE_URL=  # 百炼 Anthropic 兼容端点
LITELLM_OPENAI_QWEN_MODEL=    # OpenAI 协议模型名
LITELLM_ANTHROPIC_QWEN_MODEL= # Anthropic 协议模型名

# ===== 可选变量（接 Langfuse 时） =====
LANGFUSE_PUBLIC_KEY=          # Langfuse 公钥
LANGFUSE_SECRET_KEY=          # Langfuse 私钥

# ===== 可选变量（接 OTel 时） =====
OTEL_EXPORTER_OTLP_ENDPOINT=  # OTel 端点
OTEL_EXPORTER_OTLP_HEADERS=   # OTel 请求头
USE_OTEL_LITELLM_REQUEST_SPAN= # 是否启用 Request Span
```

### B. 目录结构

```
observability/
├── README.md              # 总览入口
├── ACCEPTANCE.md          # 本文档
├── MIGRATION.md           # 迁移指南
├── litellm/
│   ├── README.md          # LiteLLM 使用指南
│   ├── docker-compose.yml # 编排配置
│   ├── config.yaml        # LiteLLM 配置
│   └── .env.example       # 环境变量模板
└── langfuse/
    └── README.md          # 归档方案（已停用）
```

### C. 参考资料

- LiteLLM 官方文档：https://docs.litellm.ai/
- OpenTelemetry: https://opentelemetry.io/
- Braintrust: https://www.braintrust.dev/
- Arize AI: https://arize.com/
