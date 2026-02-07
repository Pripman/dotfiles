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
				ensure_installed = { 'yamlls', 'eslint', 'lua_ls', 'typos_lsp', 'graphql', 'marksman', 'docker_compose_language_service', 'ruff', 'biome', 'helm_ls', 'pyright' },
				handlers = {
					lsp_zero.default_setup,
				}
			})

			require 'lspconfig'.pyright.setup({})

			require 'lspconfig'.marksman.setup({})

			require 'lspconfig'.helm_ls.setup({
				settings = {
					['helm-ls'] = {
						yamlls = {
							path = "yaml-language-server",
						}
					}
				}
			})
			require 'lspconfig'.ruff.setup({
				init_options = {
					configurationPreference = "filesystemFirst"
				},
				on_attach = function(client, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						-- command = "!ruff check --fix %",
					})
				end,
			})
			local lspconfig = require("lspconfig")
			require 'lspconfig'.graphql.setup({
				filetypes = { 'graphql' },
				root_dir = lspconfig.util.root_pattern(".graphqlconfig", ".graphqlrc", "package.json"),
			})
			require 'lspconfig'.typos_lsp.setup({})
			require 'lspconfig'.docker_compose_language_service.setup({})
			require 'lspconfig'.biome.setup({
				filetypes = { 'ts', 'tsx' },
				root_dir = lspconfig.util.root_pattern("package.json"),
				on_attach = function(client, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format()
						end
					})
				end,

			})
			require 'lspconfig'.eslint.setup({
				on_attach = function(client, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						command = "EslintFixAll",
					})
				end,
			})
			require 'lspconfig'.yamlls.setup({
				filetypes = { 'yaml', 'yml' },

			})
			require 'lspconfig'.lua_ls.setup({
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" }
						}
					}
				},
				on_attach = function(client, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer   = bufnr,
						callback = function()
							vim.lsp.buf.format()
						end
					})
				end,
			})

			local cmp = require 'cmp'



			cmp.setup({

				sources = cmp.config.sources({
					{ name = "nvim_lsp",               keyword_length = 1 },
					{ name = "nvim_lsp_signature_help" },
					{ name = "path" },
					{ name = "nvim_lua" }
				}, {
					{ name = 'buffer' },
				}),

				mapping = cmp.mapping.preset.insert({
					['<CR>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.confirm({
								select = true,
							})
						else
							fallback()
						end
					end),
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
			cmp.setup.filetype('typescript', {
				sources = {
					{ name = "nvim_lsp",               keyword_length = 1 },
					{ name = "nvim_lsp_signature_help" },
					{ name = "path" },
					{ name = "nvim_lua" }
				}
			})
		end,
		branch = 'v3.x'
	},
	{ 'neovim/nvim-lspconfig' },
	{ 'hrsh7th/cmp-nvim-lsp' },
}
