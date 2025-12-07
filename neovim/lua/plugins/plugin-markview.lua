-- For `plugins/markview.lua` users.
return {
  "OXY2DEV/markview.nvim",
  lazy = false,
  opts = {
    enable = false,
  },
  -- 在 lazy.nvim 配置中
  keys = {
    { "<leader>md", "<cmd>Markview toggle<CR>", desc = "Toggle Markview preview" },
  },
  ft = { "markdown" },
}
