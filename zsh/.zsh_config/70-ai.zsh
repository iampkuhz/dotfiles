# =========================
# AI 默认配置（尽量把“通用默认值”放这里）
# .env 只放：密钥 / 模型名 / 少数机器差异
# =========================

# 默认供应商（可被 ~/.env 覆盖）
: ${AI_PROVIDER:=openai}

# 代码补全配置项
: ${AUTOCOMPLETE_API_BASE:=https://api.openai.com/v1}
: ${AUTOCOMPLETE_MODEL:=gpt-5.1-codex-mini}

# 聊天配置项
: ${CHAT_API_BASE:=https://generativelanguage.googleapis.com/v1beta/openai/}
: ${CHAT_API_KEY:=}
: ${CHAT_MODEL:=gemini-3-pro-preview}

# 兼容你旧变量：如果你仍然用 OLLAMA_ENDPOINT，则优先不动；
# 如果没给 OLLAMA_ENDPOINT，就从 OLLAMA_API_BASE 推导一个（保留你旧的 /v1/completions 形式）
if [[ -z "${OLLAMA_ENDPOINT:-}" ]]; then
  export OLLAMA_ENDPOINT="${OLLAMA_API_BASE%/}/v1/completions"
fi

# 本地启动 ollama start
# 注入并生效到通过 launchd 启动的服务
# launchctl setenv OLLAMA_KEEP_ALIVE 30m
# launchctl setenv OLLAMA_NUM_PARALLEL 1
# launchctl setenv OLLAMA_MAX_LOADED_MODELS 1
# brew services restart ollama
# 本地启动 ollama end
