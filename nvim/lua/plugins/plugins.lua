return {
	"tpope/vim-fugitive",
	"tpope/vim-commentary",
	"xiyaowong/transparent.nvim",
	"nvim-telescope/telescope.nvim",
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function() vim.fn["mkdp#util#install"]() end,
	}
}
