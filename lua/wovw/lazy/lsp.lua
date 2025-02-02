return {
	{
		"davidosomething/format-ts-errors.nvim",
		config = function()
			require("format-ts-errors").setup({
				add_markdown = true, -- wrap output with markdown ```ts ``` markers
				start_indent_level = 0, -- initial indent
			})
		end,
	},
	{
		'mrcjkb/rustaceanvim',
		version = '^5', -- Recommended
		lazy = false, -- This plugin is already lazy
		dependencies = {
			"neovim/nvim-lspconfig",
		},
		config = function()
			vim.g.rustaceanvim = {
				tools = {
					float_win_config = {
						border = "rounded",
						style = "minimal",
					},
				},
			}
			local bufnr = vim.api.nvim_get_current_buf()
			vim.keymap.set("n", "K", function() vim.cmd.RustLsp({ 'hover', 'actions' }) end,
				{ silent = true, buffer = bufnr, })
		end
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "KingMichaelPark/mason.nvim", opts = { pip = { use_uv = true } } },
			"KingMichaelPark/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer",
			"hrsh7th/cmp-nvim-lsp",
			"j-hui/fidget.nvim",
			"davidosomething/format-ts-errors.nvim",
		},

		config = function()
			local cmp_lsp = require("cmp_nvim_lsp")
			local capabilities = vim.tbl_deep_extend(
				"force",
				{},
				vim.lsp.protocol.make_client_capabilities(),
				cmp_lsp.default_capabilities()
			)

			local nvim_lsp = require("lspconfig")

			-- manual setup to work with NixOS
			nvim_lsp.lua_ls.setup({
				capabilities = capabilities,
				settings = {
					Lua = {},
				},
				on_init = function(client)
					if client.workspace_folders then
						local path = client.workspace_folders[1].name

						if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
							return
						end
					end

					client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
						runtime = {
							version = 'Lua 5.1'
						},
						-- Make the server aware of Neovim runtime files
						workspace = {
							checkThirdParty = false,
							library = {
								vim.env.VIMRUNTIME,
								-- Depending on the usage, you might want to add additional paths here.
								"${3rd}/luv/library"
								-- "${3rd}/busted/library",
							}
							-- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
							-- library = vim.api.nvim_get_runtime_file("", true)
						}
					})
				end,
			})
			nvim_lsp.clangd.setup({
				capabilities = capabilities,
			})
			nvim_lsp.nil_ls.setup({
				capabilities = capabilities,
				settings = {
					["nil"] = {
						formatting = {
							command = { "nixfmt" },
						},
					},
					-- https://github.com/oxalica/nil/issues/131
					nix = {
						flake = {
							-- calls `nix flake archive` to put a flake and its output to store
							autoArchive = true,
							-- auto eval flake inputs for improved completion
							autoEvalInputs = true,
						},
					},
				},
			})

			require("fidget").setup({})
			require("mason").setup()
			require("mason-tool-installer").setup({ -- used with conform.nvim
				ensure_installed = {
					"eslint_d",
					"prettierd",
					"gofumpt",
					"goimports-reviser",
					"golines",
					"codelldb",
					"delve",
				},
			})
			require("mason-lspconfig").setup({
				ensure_installed = {
					"ruff",
					"gopls",
					"ts_ls",
					"eslint",
					"tailwindcss",
					"prismals",
					"marksman",
					"zls",
				},
				automatic_installation = true,
				handlers = {
					function(server_name)
						nvim_lsp[server_name].setup({
							capabilities = capabilities,
						})
					end,
					zls = function()
						nvim_lsp.zls.setup({
							capabilities = capabilities,
							settings = {
								zls = {
									enable_inlay_hints = true,
									enable_snippets = true,
									warn_style = true,
								},
							},
						})
						vim.g.zig_fmt_parse_errors = 0
						vim.g.zig_fmt_autosave = 0
					end,
					ts_ls = function()
						nvim_lsp.ts_ls.setup({
							capabilities = capabilities,
							handlers = {
								["textDocument/publishDiagnostics"] = function(
									_,
									result,
									ctx,
									config
								)
									if result.diagnostics == nil then
										return
									end

									-- ignore some tsserver diagnostics
									local idx = 1
									while idx <= #result.diagnostics do
										local entry = result.diagnostics[idx]

										local formatter = require('format-ts-errors')[entry.code]
										entry.message = formatter and formatter(entry.message) or entry.message

										-- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
										if entry.code == 80001 then
											-- { message = "File is a CommonJS module; it may be converted to an ES module.", }
											table.remove(result.diagnostics, idx)
										else
											idx = idx + 1
										end
									end

									vim.lsp.diagnostic.on_publish_diagnostics(
										_,
										result,
										ctx,
										config
									)
								end,
							},
						})
					end,
					gopls = function()
						nvim_lsp.gopls.setup({
							capabilities = capabilities,
							settings = {
								gopls = {
									completeUnimported = true,
									usePlaceholders = true,
									analyses = {
										unusedparams = true,
									},
								}
							}
						})
					end,
				},
			})

			vim.diagnostic.config({
				float = {
					focusable = true,
					style = "minimal",
					border = "rounded",
					header = "",
					prefix = "",
					scope = "line",
				},
			})
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
				vim.lsp.handlers.hover, {
					border = "rounded",
					focusable = true,
					style = "minimal",
				}
			)
			vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
				vim.lsp.handlers.signature_help, {
					border = "rounded",
				}
			)


			vim.keymap.set("n", "gd", vim.lsp.buf.definition)
			vim.keymap.set("n", "gI", vim.lsp.buf.implementation) -- Useful when language has ways of declaring types without an actual implementation.
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
			vim.keymap.set("n", "K", vim.lsp.buf.hover)
			vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action)
			vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol)
			vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references)
			vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename)
			vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float)
			vim.keymap.set("n", "[d", vim.diagnostic.goto_next)
			vim.keymap.set("n", "]d", vim.diagnostic.goto_prev)
		end,
	},
}
