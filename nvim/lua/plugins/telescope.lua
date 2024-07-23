return {
	"nvim-telescope/telescope.nvim",
	config = function()
		local builtin = require('telescope.builtin')
		vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
		vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
		vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
		vim.keymap.set('n', '<leader>fs', builtin.git_status, {})
		vim.keymap.set('n', '<leader>fr', builtin.lsp_references, { noremap = true, silent = true })
	end,
	dependencies = { 'nvim-lua/plenary.nvim', as = "plenary" }

}
