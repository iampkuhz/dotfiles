# Observability 部署顺序（极简）

按顺序执行：
1. 先部署 Langfuse：`/Users/zhehan/Documents/tools/dotfiles/observability/langfuse/README.md`
2. 再部署 LiteLLM：`/Users/zhehan/Documents/tools/dotfiles/observability/litellm/README.md`
3. 最后把 OpenClaw 指向 LiteLLM（LiteLLM README 第 9 节）

这样 LiteLLM 启动时就能直接把日志写入 Langfuse。
