return {
	"vinnymeller/swagger-preview.nvim",
	build = function()
		os.execute("npm install -g @apidevtools/swagger-cli")
	end,
}
