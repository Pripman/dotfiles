return {
	"nvim-telescope/telescope.nvim",
	cmd = "Telescope",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
	},
	keys = {
		{ "<leader>ff", function() require("telescope.builtin").find_files() end,     desc = "Find files" },
		{ "<leader>fb", function() require("telescope.builtin").buffers() end,        desc = "Find buffers" },
		{ "<leader>fg", function() require("telescope.builtin").live_grep() end,      desc = "Live grep" },
		{ "<leader>fh", function() require("telescope.builtin").help_tags() end,      desc = "Help tags" },
		{ "<leader>fs", function() require("telescope.builtin").git_status() end,     desc = "Git status" },
		{ "<leader>gb", function() require("telescope.builtin").git_branches() end,   desc = "Git branches" },
		{ "<leader>fr", function() require("telescope.builtin").lsp_references() end, desc = "LSP references", noremap = true, silent = true },
		{ "<leader>fw", function() require("telescope.builtin").find_files({ cwd = "~/vimwiki" }) end, desc = "Find vimwiki files" },
	},
	config = function()
		local telescope = require("telescope")
		telescope.setup({
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown({}),
				},
			},
		})
		telescope.load_extension("ui-select")
	end,
}
