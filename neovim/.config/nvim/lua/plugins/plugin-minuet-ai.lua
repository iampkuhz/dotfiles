-- lua/plugins/minuet.lua
return {
  "milanglacier/minuet-ai.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  -- 配置触发规则，如果写少了，可能就不会触发autocomplete
  event = { "BufNewFile", "BufReadPost", "BufEnter" },

  opts = {
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

    provider = "openai_fim_compatible", -- 示例：走 /v1/completions
    provider_options = {
      openai_fim_compatible = {
        name = "ollama",
        end_point = "http://127.0.0.1:11434/v1/completions",
        model = os.getenv("OLLAMA_COMPLETION_MODEL"),
        -- 关键：用函数返回字面量，避免被当成 env 名字解析
        api_key = function()
          return "dummy"
        end,
        stream = true,
        optional = {
          n = 1,
          max_tokens = 96,
          top_p = 0.9,
          temperature = 0.2,
          -- 大模型返回到什么内容后停止
          stop = { "\n\n" },
        },
      },
    },
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
  },
}
