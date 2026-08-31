return {
	{
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v3.x',
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },
			{ "neovim/nvim-lspconfig" },
			{ "j-hui/fidget.nvim" },
			{ "hrsh7th/nvim-cmp" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-path" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-nvim-lua" },
			{ "hrsh7th/cmp-nvim-lsp-signature-help" },
			{ "L3MON4D3/LuaSnip" },
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
				-- The tsgo package maps to the deprecated `tsgo` lspconfig server; we
				-- enable the non-deprecated `tsc` server ourselves below, so keep mason
				-- from auto-enabling tsgo (which would attach a duplicate client).
				automatic_enable = { exclude = { 'tsgo' } },
			})

			-- Mason installs the native-preview server as the `tsgo` package, but
			-- nvim-lspconfig deprecated the `tsgo` server name in favor of `tsc`.
			-- We enable `tsc` (the non-deprecated name) and pin its cmd to the mason
			-- tsgo binary: tsc's default cmd prefers a project-local
			-- node_modules/.bin/tsc, and repos pinning classic TypeScript (e.g. 5.x)
			-- don't speak `--lsp --stdio`, so it crashes with exit code 1.
			-- (`ensure_installed` still uses `tsgo` — the mason package name.)
			vim.lsp.config.tsc = {
				cmd = { "tsgo", "--lsp", "--stdio" },
			}
			vim.lsp.enable("tsc")

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

			-- Compose with lspconfig's default eslint on_attach, which is what
			-- registers the fix-on-save command (renamed EslintFixAll ->
			-- LspEslintFixAll, now a buffer-local command). Overriding on_attach
			-- outright would drop that command and break save.
			local eslint_base_on_attach = vim.lsp.config.eslint.on_attach
			vim.lsp.config('eslint', {
				on_attach = function(client, bufnr)
					if eslint_base_on_attach then
						eslint_base_on_attach(client, bufnr)
					end
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						command = "LspEslintFixAll",
					})
				end,
			})
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
			cmp.setup.filetype({ 'markdown', 'vimwiki' }, { enabled = false })
		end,
	},
}
