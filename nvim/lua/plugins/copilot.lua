return {"github/copilot.vim", 
	config = function()
		vim.api.nvim_set_keymap("i", "<C-c>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
	end
,
	requires = { "nvim-lua/plenary.nvim" }
}
