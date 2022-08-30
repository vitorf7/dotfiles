vim.cmd [[
  augroup _general_settings
    autocmd!
    autocmd FileType qf,help,man,lspinfo nnoremap <silent> <buffer> q :close<CR> 
    autocmd TextYankPost * silent!lua require('vim.highlight').on_yank({higroup = 'Visual', timeout = 200}) 
    autocmd BufWinEnter * :set formatoptions-=cro
    autocmd FileType qf set nobuflisted
  augroup end

  augroup _git
    autocmd!
    autocmd FileType gitcommit setlocal wrap
    autocmd FileType gitcommit setlocal spell
  augroup end

  augroup _markdown
    autocmd!
    autocmd FileType markdown setlocal wrap
    autocmd FileType markdown setlocal spell
  augroup end

  augroup _auto_resize
    autocmd!
    autocmd VimResized * tabdo wincmd = 
  augroup end

  augroup _alpha
    autocmd!
    autocmd User AlphaReady set showtabline=0 | autocmd BufUnload <buffer> set showtabline=2
  augroup end

  augroup _auto_format_go
    autocmd!
    autocmd BufWritePre *.go :silent! lua require('go.format').gofmt()
  augroup end
  
  augroup _tf_filetypedetect
    silent! autocmd! filetypedetect BufRead,BufNewFile *.tf
  augroup end

  augroup _hcl_set_filetype
    autocmd!
    autocmd BufRead,BufNewFile *.hcl set filetype=hcl
  augroup end

  augroup _terraformrc_set_filetype
    autocmd!
    autocmd BufRead,BufNewFile .terraformrc,terraform.rc set filetype=hcl 
  augroup end

  augroup _tf_tfvars_set_filetype
    autocmd!
    autocmd BufRead,BufNewFile *.tf,*.tfvars set filetype=terraform 
  augroup end

  augroup _tfstate_set_filetype
    autocmd!
    autocmd BufRead,BufNewFile *.tfstate,*.tfstate.backup set filetype=json 
  augroup end

]]

