return {
	"coder/claudecode.nvim",
	dependencies = { "folke/snacks.nvim" },
	config = true,
	keys = {
		{ "<leader>a",  "<cmd>ClaudeCode --resume=<cr>",  desc = "AI/Claude Code" },
		{ "<leader>ac", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
		{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
		{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
		{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
		{ "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
		{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
		{ "<leader>as", "<cmd>ClaudeCodeSend<cr>",        mode = "v",                  desc = "Send to Claude" },
		{
			"<leader>as",
			"<cmd>ClaudeCodeTreeAdd<cr>",
			desc = "Add file",
			ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
		},
		-- Diff management
		{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
		{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny diff" },
		-- Terminal mode navigation
		{ "<C-h>", [[<C-\><C-n><C-w>h]], mode = "t", desc = "Go to left window" },
		{ "<C-j>", [[<C-\><C-n><C-w>j]], mode = "t", desc = "Go to down window" },
		{ "<C-k>", [[<C-\><C-n><C-w>k]], mode = "t", desc = "Go to up window" },
		{ "<C-l>", [[<C-\><C-n><C-w>l]], mode = "t", desc = "Go to right window" },
		{ "<leader>ac", [[<C-\><C-n><cmd>ClaudeCode<cr>]], mode = "t", desc = "Toggle Claude from terminal" },
	},
}
