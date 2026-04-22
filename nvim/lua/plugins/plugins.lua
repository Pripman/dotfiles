return {
	{
		"tpope/vim-commentary",
		event = "VeryLazy",
	},
	{
		"xiyaowong/transparent.nvim",
		event = "VeryLazy",
	},
	{
		"vimwiki/vimwiki",
		cmd = { "VimwikiIndex", "VimwikiUISelect", "VimwikiMakeDiaryNote", "VimwikiTabIndex", "VimwikiDiaryIndex" },
		ft = "vimwiki",
		keys = {
			{ "<leader>ww", "<cmd>VimwikiMakeDiaryNote<cr>", desc = "Vimwiki today's diary" },
		},
	},
	{
		"towolf/vim-helm",
		ft = "helm",
	},
}
