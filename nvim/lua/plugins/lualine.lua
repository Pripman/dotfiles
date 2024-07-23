return {
	'nvim-lualine/lualine.nvim',
	dependencies = { 'nvim-tree/nvim-web-devicons' },
	config = function()
		require('lualine').setup {
			-- options = {
			-- 	theme = 'gruvbox',
			-- 	section_separators = {'', ''},
			-- 	component_separators = {'', ''},
			-- },
			sections = {
				lualine_a = {'branch'},
				lualine_b = {'buffers'},
				lualine_c = {{'filename', path = 1}},
				lualine_x = {'filetype'},
				lualine_y = {'progress'},
				lualine_z = {'location'}
			},
			-- inactive_sections = {
			-- 	lualine_a = {},
			-- 	lualine_b = {},
			-- 	lualine_c = {'filename'},
			-- 	lualine_x = {'location'},
			-- 	lualine_y = {},
			-- 	lualine_z = {}
			-- },
			-- tabline = {},
			-- extensions = {}
		}
	end
}
