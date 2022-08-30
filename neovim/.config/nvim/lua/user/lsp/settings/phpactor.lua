local phpactor_capabilities = vim.lsp.protocol.make_client_capabilities()
phpactor_capabilities['textDocument']['codeAction'] = {}
return {
     capabilities = phpactor_capabilities,
}
