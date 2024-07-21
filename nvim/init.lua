-- bootstrap lazy.nvim,
require("config.lazy")

-- enable LazyExtras for vscode
vim.g.vscode = true

if vim.g.vscode == true then
  vim.opt.showmode = true
end
