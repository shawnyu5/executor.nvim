User pass in a table with a list of file types and commands:

```lua
require("executor").setup({
    commands = {
        cpp = {
            "make",
            "g++ %"
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
            extern = false
        },
        lua = {
            "luafile %",
            extern = false
        }
    }
    default_mappings = true

    dependency_commands = {
        make = makefile
    }
}
```

`extern` specifies weather to run command in external terminal or builtin

`default_mappings` specifies to set the default mappings or not.

`dependency_commands` table sets commands that require the existence of other
files in cwd. Such as `make` requiring the presents of `makefile`

When executing a command, it cross references the current command against the
`dependency_commands` table, to see if a dependency is required. If a dependency
file is required, it checks `cwd` for the file

   * `local function is_dependency(command)` - takes a command and parses the
   keys in the `dependency_commands` table. If the dependency is found, we check
   if it exist in current directory
