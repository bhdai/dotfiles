vim.g.mapleader = " "

local function map(mode, lhs, rhs)
	vim.keymap.set(mode, lhs, rhs, { silent = true })
end

--save
map("n", "<leader>w", ":update<CR>")

--quite
map("n", "<leader>q", ":q<CR>")

--exit insert mode you can enalbe it if you want here i comment it out cause i prefer to map the esc key to CapsLook key using powertoy
-- map("n", "jk", "<ESC>")

-- clear search with <esc>
map("n", "<ESC>", ":noh<CR><ESC>")

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Do things without affecting the registers
map("n", "x", '"_x')
map("n", "<Leader>p", '"0p')
map("n", "<Leader>P", '"0P')
map("v", "<Leader>p", '"0p')
map("n", "<Leader>c", '"_c')
map("n", "<Leader>C", '"_C')
map("v", "<Leader>c", '"_c')
map("v", "<Leader>C", '"_C')
map("n", "<Leader>d", '"_d')
map("n", "<Leader>D", '"_D')
map("v", "<Leader>d", '"_d')
map("v", "<Leader>D", '"_D')

-- select all
map("n", "<C-a>", "gg<S-v>G")

-- neo_tree
map("n", "<leader>e", ":Neotree toggle<CR>")
map("n", "<leader>r", ":Neotree focus<CR>")

-- new windows
map("n", "sv", ":vsplit<CR>")
map("n", "ss", ":split<CR>")

-- windows navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- resize windows
map("n", "<C-Left>", "<C-w><")
map("n", "<C-Right>", "<C-w>>")
map("n", "<C-Up>", "<C-w>+")
map("n", "<C-Down>", "<C-w>-")
