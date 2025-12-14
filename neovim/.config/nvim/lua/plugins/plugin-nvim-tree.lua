-- 文件目录树
-- nvimTree内部快捷键:
--  o: 打开文件或文件夹
--  a: 创建文件
--  r: 重命名
--  x: 剪切
--  c: 拷贝
--  p: 粘贴
--  d: 删除
return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup {}
  end,
}
