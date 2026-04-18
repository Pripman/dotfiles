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
				ensure_installed = { 'yamlls', 'eslint', 'lua_ls', 'typos_lsp', 'graphql', 'marksman', 'docker_compose_language_service', 'ruff', 'biome', 'helm_ls', 'pyright', 'tsgo' },
				handlers = {
					lsp_zero.default_setup,
				}
			})

			vim.lsp.enable("tsgo")

			-- Configure LSP servers using new vim.lsp.config API
			vim.lsp.config.pyright = {}
			vim.lsp.enable('pyright')

			vim.lsp.config.marksman = {}
			vim.lsp.enable('marksman')

			vim.lsp.config.helm_ls = {
				settings = {
					['helm-ls'] = {
						yamlls = {
							path = "yaml-language-server",
						}
					}
				}
			}
			vim.lsp.enable('helm_ls')

			vim.lsp.config.ruff = {
				init_options = {
					configurationPreference = "filesystemFirst"
				},
				on_attach = function(client, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({ name = "ruff" })
						end,
					})
				end,
			}
			vim.lsp.enable('ruff')

			vim.lsp.config.graphql = {
				filetypes = { 'graphql' },
				root_markers = { ".graphqlconfig", ".graphqlrc", "package.json" },
			}
			vim.lsp.enable('graphql')

			vim.lsp.config.typos_lsp = {}
			vim.lsp.enable('typos_lsp')

			vim.lsp.config.docker_compose_language_service = {}
			vim.lsp.enable('docker_compose_language_service')

			vim.lsp.config.biome = {}
			vim.lsp.enable('biome')

			vim.lsp.config.eslint = {
				on_attach = function(client, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						command = "EslintFixAll",
					})
				end,
			}
			vim.lsp.enable('eslint')

			vim.lsp.config.yamlls = {
				filetypes = { 'yaml', 'yml' },
			}
			vim.lsp.enable('yamlls')

			vim.lsp.config.lua_ls = {
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
			}
			vim.lsp.enable('lua_ls')

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
	{ "hrsh7th/nvim-cmp" },
	{ 'hrsh7th/cmp-nvim-lsp' },
	{ "L3MON4D3/LuaSnip" }
}
