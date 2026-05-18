return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"ibhagwan/fzf-lua",
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"ts_ls",
					"tailwindcss",
					"pyright",
					"html",
					"cssls",
					"clangd",
					"gopls",
					"rust_analyzer",
					"intelephense",
				},
			})

			vim.diagnostic.config({
				virtual_text = { prefix = "●" },
				float = { border = "rounded", source = "always" },
			})
			vim.o.winborder = "rounded"

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local has_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
			if has_cmp then
				capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
			end

			vim.lsp.config("*", {
				capabilities = capabilities,
				root_markers = { ".git", "wp-load.php", "composer.json" },
			})

			vim.lsp.config("intelephense", {
				settings = {
					intelephense = {
						stubs = {
							"apache",
							"bcmath",
							"bz2",
							"calendar",
							"com_dotnet",
							"Core",
							"ctype",
							"curl",
							"date",
							"dba",
							"dom",
							"enchant",
							"exif",
							"FFI",
							"fileinfo",
							"filter",
							"fpm",
							"ftp",
							"gd",
							"gettext",
							"gmp",
							"hash",
							"iconv",
							"imap",
							"intl",
							"json",
							"ldap",
							"libxml",
							"mbstring",
							"meta",
							"mysqli",
							"oci8",
							"odbc",
							"openssl",
							"pcntl",
							"pcre",
							"PDO",
							"pdo_ibm",
							"pdo_mysql",
							"pdo_pgsql",
							"pdo_sqlite",
							"pgsql",
							"Phar",
							"posix",
							"pspell",
							"random",
							"readline",
							"recode",
							"Reflection",
							"session",
							"shmop",
							"SimpleXML",
							"snmp",
							"soap",
							"sockets",
							"sodium",
							"SPL",
							"sqlite3",
							"standard",
							"superglobals",
							"sysvmsg",
							"sysvsem",
							"sysvshm",
							"tidy",
							"tokenizer",
							"xml",
							"xmlreader",
							"xmlrpc",
							"xmlwriter",
							"xsl",
							"Zend OPcache",
							"zip",
							"zlib",
							"wordpress",
						},
						environment = {
							includePaths = { "/home/zaid/Projects/wordpress-core/wordpress" },
						},
						files = { maxSize = 5000000 },
					},
				},
			})

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = { checkThirdParty = false },
					},
				},
			})

			vim.lsp.enable({
				"lua_ls",
				"ts_ls",
				"tailwindcss",
				"pyright",
				"html",
				"cssls",
				"clangd",
				"gopls",
				"rust_analyzer",
				"intelephense",
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(ev)
					local opts = { buffer = ev.buf, silent = true }
					local fzf = require("fzf-lua")
					vim.keymap.set("n", "gd", fzf.lsp_definitions, opts)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "<leader>ca", fzf.lsp_code_actions, opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				end,
			})

			vim.api.nvim_create_user_command("LspInfo", function()
				require("lspconfig.ui.windows").info()
			end, {})
		end,
	},
}
