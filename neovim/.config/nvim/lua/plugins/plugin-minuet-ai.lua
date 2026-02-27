-- lua/plugins/minuet.lua
-- 快捷键清单（每行一个）：
-- minuet-ai `<C-;>`：接受当前灰字补全。
-- minuet-ai `<C-e>`：关闭当前灰字补全提示。
return {
  "milanglacier/minuet-ai.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  -- 配置触发规则，如果写少了，可能就不会触发autocomplete
  event = { "BufNewFile", "BufReadPost", "BufEnter" },

  opts = function()
    -- 统一从 ~/.env 读取补全相关变量，避免多处配置不一致
    -- AUTOCOMPLETE_API_BASE：OpenAI 兼容接口地址（不含 /completions）
    -- AUTOCOMPLETE_API_KEY：API Key（本地模型可留空）
    -- AUTOCOMPLETE_MODEL：模型名（远端或本地）
    local api_base = os.getenv("AUTOCOMPLETE_API_BASE")
    local api_key = os.getenv("AUTOCOMPLETE_API_KEY")
    local model = os.getenv("AUTOCOMPLETE_MODEL")
    -- DashScope 兼容模式对 streaming 支持不稳定，检测到域名时关闭流式
    local is_dashscope = api_base ~= nil and api_base:find("dashscope.aliyuncs.com", 1, true) ~= nil

    -- 统一 OpenAI 兼容接口配置，按环境变量决定是远端还是本地
    local provider = "openai_fim_compatible"
    -- 如果 API Base 指向本机（localhost/127.0.0.1），视为本地服务
    local is_local = api_base ~= nil
      and (api_base:find("127.0.0.1", 1, true) ~= nil or api_base:find("localhost", 1, true) ~= nil)
    -- 只有非本地且配置了 API Base 时，才按远端处理
    local is_remote = api_base ~= nil and api_base ~= "" and not is_local
    local provider_options = {
      openai_fim_compatible = {
        name = is_remote and "remote" or "ollama",
        end_point = is_remote and (api_base .. "/completions") or "http://127.0.0.1:11434/v1/completions",
        model = model,
        -- 关键：用函数返回字面量，避免被当成 env 名字解析
        api_key = function()
          -- 远端必须要 key；本地允许空 key（返回 dummy 避免插件报错）
          if is_remote then
            return api_key or ""
          end
          return "dummy"
        end,
        stream = not is_dashscope,
        optional = {
          n = 1,
          -- 限制单次补全长度，避免一次性生成过多不准内容
          max_tokens = 24,
          top_p = 0.9,
          temperature = 0.2,
          -- 大模型返回到什么内容后停止
          stop = { "\n\n" },
        },
      },
    }

    return {
    -- Copilot 式灰字
    virtualtext = {
      -- 全文件类型自动触发（嫌贵就列举具体 ft）
      auto_trigger_ft = { "*" },
      auto_trigger_ignore_ft = {},
      -- 有下拉菜单时不显示灰字，避免视觉冲突
      show_on_completion_menu = true,
      -- 键位：推荐把“接受灰字”放在不跟 cmp 冲突的键上
      keymap = {
        -- accept = "<C-;>",
        accept = "<C-;>",
        next = nil, -- 不要循环，避免多条
        prev = nil, -- 轮换上一条
        dismiss = "<C-e>", -- 关闭
      },
    },

    -- 要几条候选（插件层面）。chat 模型=提示“希望 N 条”；FIM 模型=会发 N 次请求。
    -- LLM 不保证严格返回 N 条，但这里设 1 基本能避免 (1/2)(1/3) 的轮换。
    n_completions = 1,

    provider = provider, -- 统一走 OpenAI 兼容接口（本地或远端）
    provider_options = provider_options,
    -- 提示级别：false（全关）|"debug"|"verbose"|"warn"|"error"。
    -- 排障用 "debug"，日常建议 "warn"/"error"。
    notify = "warn",

    -- 单次请求超时（秒）。stream=true 时略小的值能更快看到第一屏；stream=false 则必须足够长。
    -- 本地 Ollama 可 8~12；远端 API 看网况。
    request_timeout = 20,

    -- 送入 LLM 的上下文“总字符数”（光标前+光标后）。注意是字符不是 token。
    -- 越大越慢；灰字应用 2000~4000 足够（默认 16000 ≈ ~4k token）。
    context_window = 16000,

    -- 光标前/后的上下文分配比例（0~1）。0.75 表示前:后≈3:1。
    -- 代码补全通常更看重光标前，0.7~0.85 都是合理区间。
    context_ratio = 0.75,

    -- 节流：在该毫秒间隔内至多发送一次请求。自动触发时很有用；手动触发可设 0。
    throttle = 1000,

    -- 防抖：停止输入后等待多少毫秒再发请求。自动触发时 250~400 较稳；手动触发 0。
    debounce = 250,

    -- 依据“光标后的真实文本”，裁剪候选末尾与后缀重复的部分。数值是“比较长度阈值”（字符数）。
    -- 例如 15：如果候选末尾有一段与后文 20 字符完全相同，就把这 20 字符从候选里剪掉。
    after_cursor_filter_length = 15,

    -- 与上类似，但裁剪“候选的前缀”。用于避免把已经打出来的前缀重复再生成一次。
    before_cursor_filter_length = 5,
    }
  end,
}
