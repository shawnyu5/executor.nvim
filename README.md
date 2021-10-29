# executor.nvim

Compiles / executes the current file(s) based on file type.

## Set up

Vim-plug

```vim
Plug 'shawnyu5/executor.nvim'

lua << EOF
require("executor").setup({
    -- where you define your own commands, or leave it empty to use default
    -- configuration
})

EOF
```

## configuration

Executor comes with the following defaults:

```lua
{
    commands = {
        -- file type
        cpp = {
            -- command(s) to excute
            "make",
            "g++ %" -- `%` represent the current file name
        },
        python = {
            "python3 %"
        },
        javascript = {
            "nodemon %"
        },
        sh = {
            "bash %"
        },
        vim = {
            "source %",
            extern = false  -- run command in pop terminal instead of terminal
                            -- in new tab
        },
        lua = {
            "luafile %",
            extern = false
        },
        markdown = {
            "MarkdownPreview",
            extern = false
        }

    },
     default_mappings = true, -- use default mapping

     dependency_commands = {
         -- the command make requires the presents of a makefile in cwd, if
         -- makefile is not found, try next command in table
         make = "makefile"
     }
}
```

## Key mappings

Executor comes with the following key mappings:

`nnoremap <leader>m :lua require('executor').executor()<CR>` - executes the
current file

`nnoremap <leader>ct :lua require('executor').term_closer()<CR>` - close all
terminal windows. Effectively running `:bd!` on all terminal tabs
