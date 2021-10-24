" echo "hiii"
" echo g:executor_map_keys

" reload this package
lua package.loaded["executor"] = nil

" nnoremap <Plug>executor <Cmd>lua require("executor").executor()<CR>
" nnoremap <Plug>termClose <Cmd>lua require("executor").term_closer()<CR>

if !exists('g:executor_map_keys')
    let g:executor_map_keys = 1
endif

if g:executor_map_keys == 1
    " echo "keys mapped"
    nnoremap <leader>m :lua require("executor").executor()<CR>
    nnoremap <leader>ct :lua require("executor").term_closer()<CR>

    " nnoremap <leader>m Executor
endif


augroup Executor
    autocmd!
augroup END
