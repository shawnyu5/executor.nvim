M = {}

-- set default values for executor
function M.set_default_values()
    Executor_commands = {
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
        },
        default_mappings = true,
        dependency_commands = {
            make = "makefile"
        }
    }
    return Executor_commands
end

-- replace % with current file name and appends ` && exit` to command
function M.replace_filename(command, current_file_name)
    return string.gsub(command, "%%", current_file_name) .. " && exit"
end

function M.is_dependency(command, list)
    for current_command, dependency in pairs(list) do
        if current_command == command then
            -- if dependency file is not in cwd,  then return false
            if M.validate_cwd_file(dependency) then
                return true
            else
                return false
            end
        end
    end
    -- else if command is not a dependency_command, return nilo
    return nil
end

-- check if the file passed in is in cwd
function M.validate_cwd_file(file_name)
    local cwd_files = vim.fn.system("ls")
    -- print("cwd files are " .. cwd_files)
    -- print("file name is " .. file_name)

    if string.find(cwd_files, string.lower(file_name)) then
        return true
    else
        return false
    end
end

return M
