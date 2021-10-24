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

-- replace % with current file name
local function replace_filename(command, current_file_name)
    return string.gsub(command, "%%", current_file_name)
end


-- excutes file based on file type
function M.executor(executorCommands)
    executorCommands = executorCommands or nil

    local current_file_name = vim.fn.expand("%")
    local current_filetype = vim.bo.filetype
    -- print(vim.fn.exists("vim.g.executorCommands"))
    if executorCommands == nil then
        -- print("table is nil, filling table")
        executorCommands = set_default_values()
    end

    -- print(vim.inspect(executorCommands))
    for filetype, command in pairs(executorCommands) do
        -- print("iteration " .. iteration)
        if current_filetype == filetype then
            -- print("command table is " .. vim.inspect(command))

            -- loop through command table
            for i = 1, #command do
                -- if extern, execute command in external terminal
                if command.extern == false then
                    print("COMMAND: " .. command[i])
                    -- vim.cmd(command[i])
                    break   -- don't keep checking after command has been excuted
                else
                    command[i] = replace_filename(command[i], current_file_name)
                    print("term_and_excute: " .. command[i])
                    -- term_and_excute(command[i] .. "\n")
                    break
                end
            end
        end
    end
end

-- M.executor()

    -- check for the existance of a make file
    -- if i == "make" then
        -- local files = vim.fn.system("ls")
        -- if string.find(files, "makefile") or string.find(files, "Makefile") then
            -- local excute_command = i .. " && exit"
            -- term_and_excute(excute_command)
        -- end
    -- end

    -- print("file type is " .. filetype)

    --[[
    if filetype == "python" then
        -- print("file type is python")
        local command = "python3 " .. current_file_name .. "&& exit\n"
        term_and_excute(command)

    elseif filetype == 'cpp' then
        vim.cmd("wa")
        local files = vim.fn.system("ls")

        -- check if make file exist in cwd
        if string.find(files, "makefile") or string.find(files, "Makefile") then
            local command = "make && exit\n"
            term_and_excute(command)
        else
            local command = "g++ " .. current_file_name .. " && ./a.out && exit\n"
            term_and_excute(command)
        end

    elseif filetype == "javascript" then
        local command = "nodemon " .. current_file_name .. " && exit\n"
        term_and_excute(command)

    elseif filetype == "sh" then
        local command = "./" .. current_file_name .. " && exit\n"
        term_and_excute(command)

    elseif filetype == "markdown" then
        vim.cmd("MarkdownPreview")

    elseif filetype == "html" then
        vim.cmd("!chrome %")

    elseif filetype == "vim" then
        vim.cmd("so %")

    elseif filetype == "lua" then
        vim.cmd("luafile %")

    else
        print("No mapping created")
    end
    ]]


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
        vim.fn.win_gotoid(win_ids[i])
        vim.fn.chansend(vim.b.terminal_job_id, "\n\nexit\n") --send exit key
        vim.fn.win_execute(win_ids[i], "close") -- close window
    end
    -- go back to the window we started with
    vim.fn.win_gotoid(current_window)

end

return M
