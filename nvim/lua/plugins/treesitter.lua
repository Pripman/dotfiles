-- nvim-treesitter `main` branch (Neovim 0.12+).
-- No more `configs.setup`; highlighting/folds/indent are opt-in per filetype.
return {
	'nvim-treesitter/nvim-treesitter',
	branch = 'main',
	lazy = false, -- main branch does not support lazy-loading
	build = ':TSUpdate',
	config = function()
		require('nvim-treesitter').setup({
			install_dir = vim.fn.stdpath('data') .. '/site',
		})

		local ensure_installed = {
			'c', 'lua', 'python', 'javascript', 'typescript', 'tsx',
			'vim', 'vimdoc', 'query', 'yaml', 'graphql',
			'markdown', 'markdown_inline',
		}
		-- Only install missing parsers (avoids rebuild churn on every startup).
		local installed = require('nvim-treesitter.config').get_installed('parsers')
		local have = {}
		for _, p in ipairs(installed) do have[p] = true end
		local missing = {}
		for _, p in ipairs(ensure_installed) do
			if not have[p] then table.insert(missing, p) end
		end
		if #missing > 0 then
			require('nvim-treesitter').install(missing)
		end

		-- Filetypes to enable treesitter highlighting for.
		-- Map filetype -> parser name (nil = same as filetype).
		local ft_to_parser = {
			c = 'c', lua = 'lua', python = 'python',
			javascript = 'javascript', typescript = 'typescript',
			typescriptreact = 'tsx', javascriptreact = 'javascript',
			vim = 'vim', help = 'vimdoc', query = 'query',
			yaml = 'yaml', graphql = 'graphql',
			markdown = 'markdown', vimwiki = 'markdown',
		}

		local max_filesize = 100 * 1024 -- 100 KB
		vim.api.nvim_create_autocmd('FileType', {
			pattern = vim.tbl_keys(ft_to_parser),
			callback = function(args)
				local buf = args.buf
				local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
				if ok and stats and stats.size > max_filesize then
					return
				end
				local parser = ft_to_parser[args.match]
				pcall(vim.treesitter.start, buf, parser)
			end,
		})
	end,
}
