-- 文件高亮、缩进工具，需要安装node
--
-- 快捷键清单（每行一个）：
-- treesitter `gnn`：初始化增量选择。
-- treesitter `grn`：扩大到下一个语法节点。
-- treesitter `grc`：扩大到语法作用域。
-- treesitter `grm`：缩小到上一个语法节点。
-- fold `zc`：关闭当前 fold。
-- fold `zo`：打开当前 fold。
-- fold `za`：切换当前 fold 开关。
-- fold `zM`：关闭所有 fold。
-- fold `zR`：打开所有 fold。
-- 缩进 `=`：按语法缩进当前行/选区。
-- 缩进 `gg=G`：从首行到末行整文件缩进。
-- folding 相关快捷键：
-- `zc` 关闭fold
-- `zo` 打开fold
-- `za` 打开/关闭fold
-- `zM` 折叠所有fold
-- `zR` 打开所有fold
--
-- WARN: indent不等于formatter，只能简单缩进对齐，无法识别语法
-- indent快捷键'=', 一般常用的indent方法 'gg=G' (跳转到第一行，然后indent到最后一行)
return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- 注意：nvim-treesitter 安装后需要编译解析器，推荐加上 build = ":TSUpdate"
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        -- 你要启用高亮的语言列表
        ensure_installed = {
          "lua",
          "python",
          "typescript",
          "javascript",
          "html",
          "css",
          "java",
          "solidity",
          "rust",
          "markdown",
          "elixir",
          "erlang",
          "scala",
          "git_config",
          "git_rebase",
          "go",
          "gpg",
          "groovy",
          "haskell",
          "json",
          "jq",
          "kotlin",
          "latex",
          "nginx",
          "ruby",
          "toml",
          "vim",
          "vimdoc",
          "xml",
          "yaml",
          "bash",
        },
        -- 或者安装所有支持的语言（但比较耗时）
        -- ensure_installed = "all",

        -- 同步安装（仅在 `ensure_installed` 为列表时有效）
        sync_install = false,

        -- 如果安装语言失败，继续其他的安装，不中断
        ignore_install = {},

        highlight = {
          enable = true, -- 启用基于 Treesitter 的语法高亮
          additional_vim_regex_highlighting = false,
        },

        -- 其它你需要启用的模块，比如增量选择、缩进、彩虹括号等，都可以在这里配置
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
        indent = {
          enable = true,
        },
      })
      --
      -- 开启 Folding
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
      -- 默认不要折叠
      -- https://stackoverflow.com/questions/8316139/how-to-set-the-default-to-unfolded-when-you-open-a-file
      vim.wo.foldlevel = 99
    end,
  },
}
