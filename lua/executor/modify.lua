local M = {}
local commands = require("executor").commands

-- returns the number of keys in a table
local function tbl_length(tbl)
    local length = 0
    for key in pairs(tbl) do
        -- print("" .. key)
        length = length + 1
    end
    return length
end
-- make sure user command selection is in command table
local function valid_input(user_input)
    -- if user input is less or equal to length of command table, then input is valid
    if tonumber(user_input) <= tbl_length(commands) and tonumber(user_input) > 0 then
        return true
    end
    -- else return false
    return false
end


local function modify()
    local tmp_file_types = vim.tbl_keys(commands)
    local file_types = ""
    for i = 1, #tmp_file_types do
        file_types = file_types .. i .. ". " .. tmp_file_types[i] .. '\n'
    end
    local user_input = vim.fn.input("Configured lanuages:\n" .. file_types .. "> ")
    -- if user didn't enter anything, then return
    if user_input == "" then
        return
    end

    -- if user input invalid, send error message
    if not valid_input(user_input) then
        print("Lanuage not configured")
        return
    end
end

modify()

return M
