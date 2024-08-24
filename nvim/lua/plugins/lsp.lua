return {
	{
		'VonHeikemen/lsp-zero.nvim',
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{
				"williamboman/mason-lspconfig.nvim",
				dependencies = {
					"williamboman/mason.nvim",
				}
			},
			"j-hui/fidget.nvim",
		},
		config = function()
			local lsp_zero = require('lsp-zero')
			lsp_zero.extend_lspconfig()
			lsp_zero.on_attach(function(client, bufnr)
				-- see :help lsp-zero-keybindings
				-- to learn the available actions
				lsp_zero.default_keymaps({ buffer = bufnr })
			end)


			require 'fidget'.setup({})
			require 'mason'.setup({})
			require 'mason-lspconfig'.setup({
				-- Replace the language servers listed here
				-- with the ones you want to install
				ensure_installed = { 'tsserver', 'ruff_lsp', 'pyright', 'yamlls', 'eslint', 'lua_ls', 'typos_lsp', 'graphql', 'marksman' },
				handlers = {
					lsp_zero.default_setup,
				}
			})

			require 'lspconfig'.marksman.setup({})
			require 'lspconfig'.pyright.setup({})
			local lspconfig = require("lspconfig")
			require 'lspconfig'.graphql.setup({
				filetypes = { 'graphql' },
    			root_dir = lspconfig.util.root_pattern(".graphqlconfig", ".graphqlrc", "package.json"),
			})
			require 'lspconfig'.typos_lsp.setup({})
			-- require 'lspconfig'.ruff_lsp.setup({})
			require 'lspconfig'.tsserver.setup({})
			require 'lspconfig'.eslint.setup({
				on_attach = function(client, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						command = "EslintFixAll",
					})
				end,
			})
			require 'lspconfig'.yamlls.setup({
				filetypes = { 'yaml', 'yml' }

			})
			require 'lspconfig'.lua_ls.setup({
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" }
						}
					}
				}
			})

			local cmp = require 'cmp'
			cmp.setup({
				mapping = cmp.mapping.preset.insert({
					['<CR>'] = cmp.mapping.confirm({ select = true }),
				}),
				preselect = 'item',
				completion = {
					completeopt = 'menu,menuone,noinsert'
				},

			})
			cmp.setup.filetype('sql', {
				sources = {
					{ name = 'vim-dadbod-completion' },
					{ name = 'buffer' },
				}
			})
		end,
		branch = 'v3.x'
	},
	{ 'neovim/nvim-lspconfig' },
	{ 'hrsh7th/cmp-nvim-lsp' },
	{ 'hrsh7th/nvim-cmp' },
	{ 'L3MON4D3/LuaSnip' }
}
