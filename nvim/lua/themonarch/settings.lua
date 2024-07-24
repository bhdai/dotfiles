local global = vim.g
local opt = vim.opt

-- editor options

opt.number = true
opt.relativenumber = true
opt.clipboard = "unnamedplus"
opt.syntax = "on"
opt.autoindent = true
opt.smartcase = true -- don't ignore case with capitals
opt.smartindent = true -- insert indent automatically
opt.spelllang = "en"
opt.cursorline = true
opt.expandtab = true -- in insert mode use the propreate number of spaces to insert a <tab>
opt.shiftwidth = 2 -- number of spaces used for autoindent
opt.tabstop = 2 -- number of spaces that tab in the a file count for
opt.encoding = "UTF-8"
opt.ruler = true -- show the line and column number of cursur position
opt.mouse = "a" -- using mouse for a(all) mode
opt.title = true -- the title of windows will be set to the value of "titlestring"
opt.hidden = true -- when on the buffer become hidden when it is abanded
opt.wildmenu = true -- command-line complete in enhance mode
opt.showcmd = true -- set if off if you feel lag or slow
opt.showmatch = true -- when the bracket is inserted briefly jump to the matching one
opt.inccommand = "split" -- When nonempty, shows the effects of :substitute, :smagic, :snomagic and user commands with the :command-preview flag as you type.
opt.splitright = true
opt.splitbelow = true
opt.termguicolors = true
opt.timeoutlen = vim.g.vscode and 1000 or 300 -- Lower than default (1000) to quickly trigger which-key
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode

if vim.fn.has("nvim-0.10") == 1 then
	opt.smoothscroll = true
	-- opt.foldexpr = "v:lua.require'lazyvim.util'.ui.foldexpr()"
	-- opt.foldmethod = "expr"
	-- opt.foldtext = ""
end
