-- 文件: lua/plugins/lsp_cmp.lua
-- 代码自动补全
return {

  -- 1. 自动补全框架 nvim-cmp 本体
  {
    "hrsh7th/nvim-cmp",
    -- nvim-cmp 依赖的补全源和 snippet 引擎
    dependencies = {
      -- LSP 补全源
      "hrsh7th/cmp-nvim-lsp",
      -- 从 buffer 里补全
      "hrsh7th/cmp-buffer",
      -- 路径补全
      "hrsh7th/cmp-path",
      -- snippet 引擎
      "L3MON4D3/LuaSnip",
      -- LuaSnip 的补全源
      "saadparwaiz1/cmp_luasnip",
      -- 可选，提供美观图标
      "onsails/lspkind-nvim",
      -- 可选，提供丰富的预置 snippet
      "rafamadriz/friendly-snippets",
      -- 命令行补全
      "hrsh7th/cmp-cmdline",
      -- lsp补全
      "hrsh7th/cmp-nvim-lsp",
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
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- 回车确认
          ["<Tab>"] = cmp.mapping.select_next_item(), -- Tab 切换
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
        -- 可选：使用 lspkind 增强显示
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
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

      -- 如果还想配置其它语言服务器，比如 tsserver
      -- lspconfig.tsserver.setup({
      --   capabilities = capabilities,
      --   on_attach = function(client, bufnr)
      --     -- ...
      --   end,
      -- })
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
          "lua_ls",

          -- rust support
          "rust_analyzer",

          -- markdown
          "grammarly",

          -- java
          "ast_grep",

          -- solidity
          "solc",

          -- "tsserver",
          -- "pyright",
          -- "bashls",
          -- ...
          --
        },
      })
    end,
  },
}
