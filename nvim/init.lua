-- general
vim.cmd 'set number relativenumber'
vim.cmd 'set nowrap'
vim.cmd 'setlocal spell spelllang=en_us'

-- Needed for vim wiki
vim.cmd[[
	set nocompatible
	filetype plugin on
	syntax on
	let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': 'md'}]
	let g:vimwiki_global_ext = 1
]]
-- adds transparency to the background
vim.cmd [[
  highlight Normal guibg=none
  highlight NonText guibg=none
  highlight Normal ctermbg=none
  highlight NonText ctermbg=none
]]


-- set yank to copy to clipboard
vim.cmd 'set clipboard=unnamed'

-- set leader key to space
vim.g.mapleader = " "

-- Use jj to go to normal mode
vim.keymap.set("i", "jj", '<Esc>', { remap = false })

-- go to previous open buffer
vim.keymap.set("n", "<leader>b", '<cmd>:e#<cr>', { remap = false })

-- go to previous buffer
vim.keymap.set("n", "<leader>j", '<cmd>:bp<cr>', { remap = false })

-- go to next buffer
vim.keymap.set("n", "<leader>k", '<cmd>:bn<cr>', { remap = false })

-- closse buffer
vim.keymap.set("n", "<leader>q", '<cmd>:bd<cr>', { remap = false })

-- Move paane right
vim.keymap.set("n", "<C-l>", '<C-w>l', { remap = false })

-- Move paane right
vim.keymap.set("n", "<C-h>", '<C-w>h', { remap = false })

-- Move paane down 
vim.keymap.set("n", "<C-j>", '<C-w>j', { remap = false })

-- Move paane up
vim.keymap.set("n", "<C-k>", '<C-w>k', { remap = false })

-- split window vertically
vim.keymap.set("n", "<leader>v", '<C-w>v', { remap = false })

-- split window horizontally 
vim.keymap.set("n", "<leader>h", '<C-w>s', { remap = false })


-- enable normal mode in terminal
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]])

-- open diagnostic in floating window
vim.keymap.set('n', '<leader>dd', vim.diagnostic.open_float, { remap = false })

-- toggle relativenumber
vim.keymap.set("n", "<leader>r", '<cmd>:set nonumber relativenumber<cr>', { remap = false })
vim.keymap.set("n", "<leader>n", '<cmd>:set number norelativenumber<cr>', { remap = false })

-- save
vim.keymap.set("n", "<leader>s", "<Esc>:w<cr>", { remap="false", desc = "Save" })

-- autosave when leaving a file
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost" }, {
  callback = function()
    if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" and vim.bo.buftype == "" then
      vim.api.nvim_command('silent update')
    end
  end,
})




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
