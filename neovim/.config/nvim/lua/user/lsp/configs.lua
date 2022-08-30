local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not status_ok then
	return
end

local lspconfig = require("lspconfig")

local servers = { "jsonls", "sumneko_lua", "gopls", "intelephense", "phpactor", "terraformls", "tflint", "golangci_lint_ls" }

lsp_installer.setup({
	ensure_installed = servers,
})

local configs = require 'lspconfig/configs'
local util = require 'lspconfig.util'
if not configs.golangcilsp then
 	configs.golangcilsp = {
    default_config = {
      cmd = { 'golangci-lint-langserver' },
      filetypes = { 'go', 'gomod' },
      init_options = {
        command = { 'golangci-lint', 'run', '--out-format', 'json' },
      },
      root_dir = function(fname)
        return util.root_pattern 'go.work'(fname) or util.root_pattern('go.mod', '.golangci.yaml', '.golangci.yml', '.git')(fname)
      end,
    },
	}
end

for _, server in pairs(servers) do
	local opts = {
		on_attach = require("user.lsp.handlers").on_attach,
		capabilities = require("user.lsp.handlers").capabilities,
	}
	local has_custom_opts, server_custom_opts = pcall(require, "user.lsp.settings." .. server)
	if has_custom_opts then
		opts = vim.tbl_deep_extend("force", opts, server_custom_opts)
	end
	lspconfig[server].setup(opts)
end
