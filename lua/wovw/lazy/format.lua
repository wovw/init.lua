return {
	"stevearc/conform.nvim",
	dependencies = { "KingMichaelPark/mason.nvim" },
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
			end,
			mode = { "n", "v" },
			desc = "Format buffer",
		},
	},
	config = function()
		require("conform").setup({
			notify_on_error = false,
			notify_no_formatters = false,
			default_format_opts = {
				timeout_ms = 3000,
				async = false,
				quiet = false,
				lsp_format = "fallback",
			},
			format_on_save = function(bufnr)
				local disable_filetypes = { c = true, cpp = true }
				local lsp_format_opt
				if disable_filetypes[vim.bo[bufnr].filetype] then
					lsp_format_opt = "never"
				else
					lsp_format_opt = "fallback"
				end
				return {
					timeout_ms = 3000,
					lsp_format = lsp_format_opt,
				}
			end,
			formatters_by_ft = {
				typescript = { "prettierd" },
				javascript = { "prettierd" },
				typescriptreact = { "prettierd" },
				javascriptreact = { "prettierd" },
				json = { "prettierd" },
				html = { "prettierd" },
				css = { "prettierd" },

				python = { "ruff" },
				go = { "gofumpt", "goimports-reviser", "golines" },
				rust = { "rustfmt" },

				cpp = { "clang-format" },
				c = { "clang-format" },
				h = { "clang-format" },
				hpp = { "clang-format" },
				cmake = { "cmakelang" },

				["markdown"] = { "prettierd", "markdownlint-cli2", "markdown-toc" },
				["markdown.mdx"] = { "prettierd", "markdownlint-cli2", "markdown-toc" },

				["_"] = { "trim_whitespace" },
			},
			---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
			formatters = {
				injected = { options = { ignore_errors = true } },
				["markdown-toc"] = {
					condition = function(_, ctx)
						for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
							if line:find("<!%-%- toc %-%->") then
								return true
							end
						end
						return false
					end,
				},
				["markdownlint-cli2"] = {
					condition = function(_, ctx)
						local diag = vim.tbl_filter(function(d)
							return d.source == "markdownlint"
						end, vim.diagnostic.get(ctx.buf))
						return #diag > 0
					end,
				},
			},
		})
	end,
}
