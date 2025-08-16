-- 文件: lua/plugins/lsp_cmp.lua
-- 代码自动补全配置
-- sdt启用代码自动补全功能，结合nvim-cmp插件配置
return {
  {
    "milanglacier/minuet-ai.nvim",
    -- 许多插件会用到 plenary；如果你环境里已有可省略
    dependencies = { "nvim-lua/plenary.nvim" },
    -- 懒加载策略：只要你愿意，也可以加 event/keys，不过你已在 cmp 那边引用到它了
    config = function()
      -- 读取环境变量
      local provider = (vim.env.AI_PROVIDER or ""):lower()
      local provider_name = ""
      -- 根据 provider 组装 providers 表
      local providers = {}
      if provider == "openai" then
        provider_name = "openai"
        -- 严格检查 key，避免“按了 <A-y> 没反应”
        local key = vim.env.OPENAI_API_KEY
        if key and key ~= "" then
          providers.openai_fim_compatible = {
            api_key = "OPENAI_API_KEY",
            model = vim.env.OPENAI_MODEL or "gpt-5-nano",
            stream = true, -- 需要流式就 true；多数补全场景 false 即可
            optional = {
              -- 生成控制
              max_completion_tokens = 256, -- 最多生成多少 tokens（直接决定花费，越小越省钱）
              n = 1, -- 一次要几条候选（>1 会翻倍花钱；建议 1）
              user = "nvim", -- 传给 OpenAI 的 user 字段（审计/限流维度）
            },
          }
        else
          vim.notify("[minuet] OPENAI_API_KEY 未设置，已跳过 openai provider", vim.log.levels.WARN)
        end
      elseif provider == "ollama" then
        provider_name = "openai_fim_compatible"
        providers.openai_fim_compatible = {
          api_key = "TERM",
          end_point = vim.env.OLLAMA_ENDPOINT or "http://127.0.0.1:11434/v1/completions",
          model = vim.env.OLLAMA_MODEL or "qwen2.5-coder:0.5b",
          -- options = { temperature = 0.1 },
        }
      else
        -- 未设置或不认识的 provider：允许空配置启动（<A-y> 会提示未配置）
        vim.notify(
          "[minuet] 未设置或不支持的 AI_PROVIDER，minuet 将以默认/禁用状态运行",
          vim.log.levels.INFO
        )
      end

      -- 最小化配置：保持默认，先跑通链路
      require("minuet").setup({
        provider = provider_name,
        request_timeout = 8,
        notify = "debug",
        n_completions = 1,
        context_window = 500,
        provider_options = providers,
      })
    end,
  },

  -- 1. 自动补全框架 nvim-cmp 本体
  {
    "hrsh7th/nvim-cmp",
    -- nvim-cmp 依赖的补全源和 snippet 引擎
    dependencies = {
      -- LSP 补全源, 显示每个候选来源自哪个插件
      "hrsh7th/cmp-nvim-lsp",
      -- 从 buffer 里补全, 从当前buffer文本里面提取词条做不全
      "hrsh7th/cmp-buffer",
      -- 路径补全
      "hrsh7th/cmp-path",
      -- snippet 引擎，可以展示snippets
      "L3MON4D3/LuaSnip",
      -- LuaSnip 的补全源, 候选列表会由snippet条目，图标不同
      "saadparwaiz1/cmp_luasnip",
      -- 可选，提供美观图标, 给候选加上 图标+类型名
      "onsails/lspkind-nvim",
      -- 可选，提供丰富的预置 snippet
      "rafamadriz/friendly-snippets",
      -- 命令行补全, 让 /,: 命令行模式也可以支持自动补全
      "hrsh7th/cmp-cmdline",
    },
    config = function()
      -- 引入 nvim-cmp
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")
      -- 可选：加载 friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      -- 基本配置
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body) -- 让 nvim-cmp 调用 LuaSnip 来处理 snippet
          end,
        },
        mapping = {
          ["<C-;>"] = require("minuet").make_cmp_map(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- 回车确认
          ["<Tab>"] = cmp.mapping.select_next_item(), -- Tab 切换
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        },
        sources = cmp.config.sources({
          { name = "minuet" },
          {
            name = "nvim_lsp",
            entry_filter = function(entry, _)
              local K = require("cmp.types").lsp.CompletionItemKind
              return entry:get_kind() ~= K.Snippet
            end,
          },
          { name = "luasnip" },
        }, {
          { name = "buffer", keyword_length = 2, max_item_count = 5 },
          { name = "path" },
        }),
        performance = {
          fetching_timeout = 8000,
        },
        -- 可选：使用 lspkind 增强显示
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 100,
            ellipsis_char = "...",
            before = function(entry, vim_item)
              local menu =
                { minuet = "[AI]", nvim_lsp = "[LSP]", luasnip = "[SNIP]", buffer = "[BUF]", path = "[PATH]" }
              vim_item.menu = menu[entry.source.name] or ""
              vim_item.dup = ({ nvim_lsp = 0, buffer = 1, path = 1, luasnip = 1 })[entry.source.name] or 0
              return vim_item
            end,
          }),
        },
      })
      -- 为 `/` 搜索模式配置补全
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      -- 为 `:` 命令行模式配置补全
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
      -- 添加命令行模式的 Tab 键补全映射
      vim.api.nvim_set_keymap("c", "<Tab>", "v:lua.cmp#complete()", { noremap = true, expr = true })
    end,
  },

  -- 2. nvim-lspconfig：配置语言服务器
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      -- 让 cmp-nvim-lsp 获取正确的 capabilities
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- 例：配置 lua_ls（原 sumneko_lua）语言服务器
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" }, -- 忽略对全局 vim 的警告
            },
          },
        },
      })
    end,
  },

  -- 3. 可选：williamboman/mason.nvim + mason-lspconfig.nvim
  -- 让你轻松安装各种语言服务器，不用手动安装
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "rust_analyzer",--[[ markdown ]]
          "grammarly", --[[ java ]]
          "ast_grep",
          "solc",
        },
      })
    end,
  },
}
