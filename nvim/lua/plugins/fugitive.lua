return { "tpope/vim-fugitive", name="fugitive",
	config = function()
		vim.keymap.set("n", "<leader>gg", '<cmd>:tab Git<cr>', {remap = false})
	end
}
