return {
	"github/copilot.vim",
	event = "InsertEnter",
	cmd = "Copilot",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		vim.api.nvim_set_keymap("i", "<C-c>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
	end,
}
