return {
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
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
		-- https://github.com/LazyVim/LazyVim/blob/ec5981dfb1222c3bf246d9bcaa713d5cfa486fbd/lua/lazyvim/plugins/extras/lang/rust.lua#L58
		'mrcjkb/rustaceanvim',
		version = '^5', -- Recommended
		lazy = false, -- This plugin is already lazy
		ft = { "rust" },
		dependencies = {
			"neovim/nvim-lspconfig",
		},
		config = function()
			local diagnostics = "rust-analyzer"
			local opts = {
				server = {
					default_settings = {
						-- rust-analyzer language server configuration
						["rust-analyzer"] = {
							cargo = {
								allFeatures = true,
								loadOutDirsFromCheck = true,
								buildScripts = {
									enable = true,
								},
							},
							-- Add clippy lints for Rust if using rust-analyzer
							checkOnSave = diagnostics == "rust-analyzer",
							-- Enable diagnostics if using rust-analyzer
							diagnostics = {
								enable = diagnostics == "rust-analyzer",
							},
							procMacro = {
								enable = true,
								ignored = {
									["async-trait"] = { "async_trait" },
									["napi-derive"] = { "napi" },
									["async-recursion"] = { "async_recursion" },
								},
							},
							files = {
								excludeDirs = {
									".direnv",
									".git",
									".github",
									".gitlab",
									"bin",
									"node_modules",
									"target",
									"venv",
									".venv",
								},
							}
						}
					}
				}
			}

			-- dap config
			local package_path = require("mason-registry").get_package("codelldb"):get_install_path()
			local codelldb = package_path .. "/extension/adapter/codelldb"
			local library_path = package_path .. "/extension/lldb/lib/liblldb.dylib"
			local uname = io.popen("uname"):read("*l")
			if uname == "Linux" then
				library_path = package_path .. "/extension/lldb/lib/liblldb.so"
			end
			opts.dap = {
				adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb, library_path),
			}

			-- plugin config
			vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {
				tools = {
					float_win_config = {
						border = "rounded",
						style = "minimal",
					},
				},
			}, opts or {})

			-- keybinds
			local bufnr = vim.api.nvim_get_current_buf()
			vim.keymap.set("n", "K", function() vim.cmd.RustLsp({ 'hover', 'actions' }) end,
				{ silent = true, buffer = bufnr, })
			vim.keymap.set("n", "<leader>rca", function()
				vim.cmd.RustLsp("codeAction")
			end, { desc = "Code Action", buffer = bufnr })
			vim.keymap.set("n", "<leader>rd", function()
				vim.cmd.RustLsp("debuggables")
			end, { desc = "Rust Debuggables", buffer = bufnr })
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
			"p00f/clangd_extensions.nvim",
			"folke/neoconf.nvim",
		},
		opts = {
			setup = {
				clangd = function(_, opts)
					local clangd_ext_opts = require("lazy.core.config").plugins
						["clangd_extensions.nvim"].opts
					require("clangd_extensions").setup(vim.tbl_deep_extend("force",
						clangd_ext_opts or {},
						{ server = opts }))
					return false
				end,
			},
		},

		config = function()
			local cmp_lsp = require("cmp_nvim_lsp")
			local capabilities = vim.tbl_deep_extend(
				"force",
				{
					offsetEncoding = { "utf-16" },
				},
				vim.lsp.protocol.make_client_capabilities(),
				cmp_lsp.default_capabilities()
			)

			require("neoconf").setup({})

			local nvim_lsp = require("lspconfig")

			------ some LSPs need manual setup to work with NixOS ------

			-- lua_ls
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

					client.config.settings.Lua = vim.tbl_deep_extend('force',
						client.config.settings.Lua, {
							runtime = {
								version = 'Lua 5.1'
							},
						})
				end,
			})

			-- clangd (https://www.lazyvim.org/extras/lang/clangd)
			nvim_lsp.clangd.setup({
				keys = {
					{ "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
				},
				root_dir = function(fname)
					return require("lspconfig.util").root_pattern(
							"Makefile",
							"configure.ac",
							"configure.in",
							"config.h.in",
							"meson.build",
							"meson_options.txt",
							"build.ninja"
						)(fname) or
						require("lspconfig.util").root_pattern("compile_commands.json",
							"compile_flags.txt")(
							fname
						) or require("lspconfig.util").find_git_ancestor(fname)
				end,
				capabilities = capabilities,
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
					"--function-arg-placeholders",
					"--fallback-style=llvm",
				},
				init_options = {
					usePlaceholders = true,
					completeUnimported = true,
					clangdFileStatus = true,
				},
			})

			-- nil_ls
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
			------ end of manual setup ------

			require("fidget").setup({})
			require("mason").setup()
			require("mason-tool-installer").setup({ -- used with conform.nvim / DAP
				ensure_installed = {
					-- js
					"prettierd",

					-- markdown
					"markdownlint-cli2",
					"markdown-toc",

					-- go
					"gofumpt",
					"goimports-reviser",
					"golines",
					"gomodifytags",
					"impl",
					"delve",

					-- c, cpp, rust
					"codelldb",
					"cmakelang",
					"cmakelint",
				},
			})
			require("mason-lspconfig").setup({
				ensure_installed = {
					"ruff",
					"pyright",
					"basedpyright",

					"ts_ls",
					"eslint",
					"tailwindcss",
					"prismals",

					"gopls",
					"marksman",
					"jsonls",
					"zls",
					"neocmake",
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

										local formatter = require(
											'format-ts-errors')[entry.code]
										entry.message = formatter and
											formatter(entry.message) or entry
											.message

										-- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
										if entry.code == 80001 then
											-- { message = "File is a CommonJS module; it may be converted to an ES module.", }
											table.remove(result.diagnostics,
												idx)
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
					eslint = function()
						-- https://github.com/LazyVim/LazyVim/blob/ec5981dfb1222c3bf246d9bcaa713d5cfa486fbd/lua/lazyvim/plugins/extras/linting/eslint.lua
						nvim_lsp.eslint.setup({
							capabilities = capabilities,
							settings = {
								eslint = {
									-- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
									workingDirectories = {
										mode = "auto",
									},
									format = true,
								},
							},
						})
					end,
					gopls = function()
						-- https://www.lazyvim.org/extras/lang/go
						nvim_lsp.gopls.setup({
							capabilities = capabilities,
							settings = {
								gopls = {
									gofumpt = true,
									codelenses = {
										gc_details = false,
										generate = true,
										regenerate_cgo = true,
										run_govulncheck = true,
										test = true,
										tidy = true,
										upgrade_dependency = true,
										vendor = true,
									},
									hints = {
										assignVariableTypes = true,
										compositeLiteralFields = true,
										compositeLiteralTypes = true,
										constantValues = true,
										functionTypeParameters = true,
										parameterNames = true,
										rangeVariableTypes = true,
									},
									analyses = {
										nilness = true,
										unusedparams = true,
										unusedwrite = true,
										useany = true,
									},
									usePlaceholders = true,
									completeUnimported = true,
									staticcheck = true,
									directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
									semanticTokens = true,
								}
							},
							on_attach = function(client, _)
								-- workaround for gopls not supporting semanticTokensProvider
								-- https://github.com/golang/go/issues/54531#issuecomment-1464982242
								if not client.server_capabilities.semanticTokensProvider then
									local semantic = client.config.capabilities
										.textDocument.semanticTokens
									client.server_capabilities.semanticTokensProvider = {
										full = true,
										legend = {
											tokenTypes = semantic.tokenTypes,
											tokenModifiers = semantic
												.tokenModifiers,
										},
										range = true,
									}
								end
							end
						})
					end,
					ruff = function()
						nvim_lsp.ruff.setup({
							capabilities = capabilities,
							cmd_env = { RUFF_TRACE = "messages" },
							init_options = {
								settings = {
									logLevel = "error",
								},
							},
							on_attach = function(client, _)
								-- Disable hover in favor of Pyright
								client.server_capabilities.hoverProvider = false
							end,
						})
					end,
					tailwindcss = function()
						nvim_lsp.tailwindcss.setup({
							capabilities = capabilities,
							root_dir = function(fname)
								-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/tailwindcss.lua
								local util = require('lspconfig.util')
								local root_file = {
									'tailwind.config.js',
									'tailwind.config.cjs',
									'tailwind.config.mjs',
									'tailwind.config.ts',
									'postcss.config.js',
									'postcss.config.cjs',
									'postcss.config.mjs',
									'postcss.config.ts',
								}
								root_file = util.insert_package_json(root_file, 'tailwindcss', fname)

								return util.root_pattern('.git')(fname) -- added git root for monorepo support
									or util.root_pattern(unpack(root_file))(fname)
							end,
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
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
		end,
	},
}
