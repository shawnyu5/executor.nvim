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

local stuff = {
    "shawn",
    "apple"
}

-- print(vim.inspect(executorCommands))
-- for i = 1, #stuff do
    -- print(stuff[i])
-- end

local iteration = 1
for key, value in pairs(executorCommands) do
    print("iteration " .. iteration)
    print(key, vim.inspect(value))
    iteration = iteration + 1
end
