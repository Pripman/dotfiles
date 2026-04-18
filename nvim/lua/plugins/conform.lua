return { -- Autoformat
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true, lsp_format = "never" })
			end,
			mode = "",
			desc = "[F]ormat buffer",
		},
	},
	opts = {
		notify_on_error = false,
		format_on_save = function(bufnr)
			local lsp_format_opt = "first"
			return {
				filter = function(client)
					if client.name == "eslint" then
						return false
					end
					return true
				end,
				timeout_ms = 500,
				lsp_format = lsp_format_opt,
			}
		end,
		formatters = {
			biome = { require_pwd = true },
			["biome-organize-imports"] = { require_pwd = true },
		},
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "biome", "biome-organize-imports" },
			javascriptreact = { "biome", "biome-organize-imports" },
			typescript = { "biome", "biome-organize-imports" },
			typescriptreact = { "eslint", "biome", "biome-organize-imports" },
			go = { "goimports", "gofmt" },
			rust = { "rustfmt" },
		},
	},
}
