vim.cmd 'set number relativenumber'
vim.cmd 'set nowrap'
vim.cmd 'setlocal spell spelllang=en_us'


-- set yank to copy to clipboard
vim.cmd 'set clipboard=unnamed'

-- set leader key to space
vim.g.mapleader = " "

-- go to previous open buffer
vim.keymap.set("n", "<leader>b", '<cmd>:e#<cr>', { remap = false })

-- go to previous buffer
vim.keymap.set("n", "<leader>j", '<cmd>:bp<cr>', { remap = false })

-- go to next buffer
vim.keymap.set("n", "<leader>k", '<cmd>:bn<cr>', { remap = false })

-- closse buffer
vim.keymap.set("n", "<leader>w", '<cmd>:bd<cr>', { remap = false })

-- enable normal mode in terminal
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]])

-- open diagnostic in floating window
vim.keymap.set('n', '<leader>dd', vim.diagnostic.open_float, { remap = false })

-- toggle relativenumber
vim.keymap.set("n", "<leader>r", '<cmd>:set nonumber relativenumber<cr>', { remap = false })
vim.keymap.set("n", "<leader>n", '<cmd>:set number norelativenumber<cr>', { remap = false })

-- set up lazy package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- load plugins from files in the lua/plugins folder
require("lazy").setup("plugins")
