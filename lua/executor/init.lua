M = {}
Executor_commands = {}

local utils = require("executor.utils")

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


function M.setup(settings)
    if settings == nil then
        Executor_commands = utils.set_default_values()
        -- nnoremap <leader>m :lua require("executor").executor()<CR>
        -- nnoremap <leader>ct :lua require("executor").term_closer()<CR>
        vim.api.nvim_set_keymap("n", "<leader>m", ":lua require('executor').executor()<CR>", {silent = false})
        vim.api.nvim_set_keymap("n", "<leader>ct", ":lua require('executor').term_closer()<CR>", {silent = false})
    else
        Executor_commands = settings.command
    end
end

-- excutes file based on file type
function M.executor(executorCommands)
    local current_file_name = vim.fn.expand("%")
    local current_filetype = vim.bo.filetype

    for filetype, command_tbl in pairs(Executor_commands) do
        if current_filetype == filetype then
            -- loop through command table and excute command
            for i = 1, #command_tbl do
                local current_command = command_tbl[i]

                print("checking dependencies...")
                -- check if current command requires a helper file in cwd, ie `make` -> `makefile`
                if not utils.is_dependency(current_command, Executor_commands.dependency_commands) then
                    print("dependency for " .. current_command .. " not found")
                    -- if dependency not found, skip command
                    goto continue
                end
                -- if extern, execute command in external terminal
                if command_tbl.extern == false then
                    vim.cmd(current_command)
                    -- don't keep checking after command has been excuted
                    break
                else
                    current_command = utils.replace_filename(current_command, current_file_name)
                    term_and_excute(current_command .. "\n")
                    break
                end
                ::continue::
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
        vim.fn.win_gotoid(win_ids[i])
        vim.cmd("bd!")
        -- vim.fn.chansend(vim.b.terminal_job_id, "\n\nexit\n") --send exit key
        -- vim.fn.win_execute(win_ids[i], "close") -- close window
    end
    -- go back to the window we started with
    vim.fn.win_gotoid(current_window)

end

return M
