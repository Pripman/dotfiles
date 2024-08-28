-- return {
-- 	"tanvirtin/monokai.nvim",
-- 	config = function()
-- 		require('monokai').setup()
-- 		vim.cmd.colorscheme('monokai')
-- 	end
-- }
return {
	"rose-pine/neovim",
	as = "rose-pine",
	config = function()
		require('rose-pine').setup({
			variant = 'moon',
			dark_variant = 'moon',
			styles = {
				transparency = true,
			}
		})
		vim.cmd.colorscheme('rose-pine')
	end
}
