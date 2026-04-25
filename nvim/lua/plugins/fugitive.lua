return {
	"tpope/vim-fugitive",
	name = "fugitive",
	cmd = { "G", "Git", "Gdiffsplit", "Gread", "Gwrite", "Gblame", "Gclog", "GBrowse" },
	keys = {
		{ "<leader>gg", "<cmd>tab Git<cr>", desc = "Fugitive tab status" },
	},
}
