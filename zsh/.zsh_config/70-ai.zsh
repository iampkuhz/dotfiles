# =========================
# AI 默认配置（尽量把“通用默认值”放这里）
# .env 只放：密钥 / 模型名 / 少数机器差异
# =========================

# 默认供应商（可被 ~/.env 覆盖）
: ${AI_PROVIDER:=openai}

# OpenAI：默认基地址（一般不用放到 ~/.env）
: ${OPENAI_API_BASE:=https://api.openai.com/v1}

# Ollama：默认基地址（M4 Pro 本机一般就是这个；M1 若连远端再在 ~/.env 覆盖）
: ${OLLAMA_API_BASE:=http://127.0.0.1:11434}

# 默认模型（你说先用 codex-mini，就给个默认；也可在 ~/.env 覆盖）
: ${OPENAI_MODEL:=gpt-5.1-codex-mini}

# Ollama 行内补全模型默认值（可在 ~/.env 覆盖）
: ${OLLAMA_AUTOCOMPLETE_MODEL:=qwen2.5-coder-feipi:0.5b_boost2}

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
