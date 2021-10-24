" echo "hiii"
" echo g:executor_map_keys

lua << EOF
-- reload this package
package.loaded["executor"] = nil
local executor = require("executor")
executor.setup()

EOF
" nnoremap <Plug>executor <Cmd>lua require("executor").executor()<CR>
" nnoremap <Plug>termClose <Cmd>lua require("executor").term_closer()<CR>

" if !exists('g:executor_map_keys')
    " let g:executor_map_keys = 1
" endif

" if g:executor_map_keys == 1
    " " echo "keys mapped"
    " nnoremap <leader>m :lua require("executor").executor()<CR>
    " nnoremap <leader>ct :lua require("executor").term_closer()<CR>
" endif


augroup Executor
    autocmd!
augroup END
