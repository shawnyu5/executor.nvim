local M = {}
local commands = require("executor").commands
-- print(vim.inspect(commands))

local function modify()
    local tmp_file_types = vim.tbl_keys(commands)
    local file_types = ""
    for i = 1, #tmp_file_types do
        file_types = file_types .. tmp_file_types[i] .. '\n'
    end
    -- print(file_types)
    vim.fn.input("Configured lanuages:\n" .. file_types .. "> ")
end

modify()

return M
