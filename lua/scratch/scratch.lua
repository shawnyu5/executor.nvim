local executorCommands = {
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

local string = "hello %"

print(string)
print(string.gsub(string, "%%", "worlddd"))
