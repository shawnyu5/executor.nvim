M = {}
-- opens a terminal in new tab and excute command
local function term_and_excute(command)
    -- get current tab number
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("write")
    vim.cmd("tabe | term")
    -- move terminal to 1 before current tab, so closing terminal will land on the currect page
    vim.cmd("tabm " .. current_tab - 1)
    vim.fn.chansend(vim.b.terminal_job_id, command)
    vim.cmd("norm! i")
end


-- set default values for executor
local function set_default_values()
    return {
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
end

-- replace % with current file name and appends ` && exit` to command
local function replace_filename(command, current_file_name)
    return string.gsub(command, "%%", current_file_name) .. " && exit"
end

-- checks for a file's existance in the current dir
local function check_file_existance(file)
    local files =
end
-- excutes file based on file type
function M.executor(executorCommands)
    executorCommands = executorCommands or nil
    if executorCommands == nil then
        executorCommands = set_default_values()
    end

    local current_file_name = vim.fn.expand("%")
    local current_filetype = vim.bo.filetype

    for filetype, command in pairs(executorCommands) do
        if current_filetype == filetype then
            -- loop through command table and excute command
            for i = 1, #command do
                check_file_existance(command)
                -- if extern, execute command in external terminal
                if command.extern == false then
                    vim.cmd(command[i])
                    -- don't keep checking after command has been excuted
                    break
                else
                    command[i] = replace_filename(command[i], current_file_name)
                    term_and_excute(command[i] .. "\n")
                    break
                end
            end
        end
    end
end

-- M.executor()

-- exists and closes all term buffers
function M.term_closer()
    local win_ids = {}
    -- remember current window
    local current_window = vim.fn.win_getid()

    -- from tab 1 to last tab open
    for i = 1, vim.fn.tabpagenr("$") do
        -- if buffer is a terminal, we close it
        if vim.fn.gettabwinvar(i, 1, "&buftype") == "terminal" then
            local win_id = vim.fn.win_getid(1, i)
            table.insert(win_ids, win_id)
        end
    end

    -- go to all windows, send tell terminal to exit and close tab
    for i = 1, #win_ids do
        vim.cmd("bd!")
        -- vim.fn.win_gotoid(win_ids[i])
        -- vim.fn.chansend(vim.b.terminal_job_id, "\n\nexit\n") --send exit key
        -- vim.fn.win_execute(win_ids[i], "close") -- close window
    end
    -- go back to the window we started with
    vim.fn.win_gotoid(current_window)

end

return M
