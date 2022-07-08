local M = {}

-- set default values for executor
function M.set_default_values()
	return {
		commands = {
			cpp = {
				"make",
				"g++ % && ./a.out",
			},
			python = {
				"python3 %",
			},
			javascript = {
				"node %",
			},
			sh = {
				"bash %",
			},
			vim = {
				"source %",
				extern = false,
			},
			lua = {
				"luafile %",
				extern = false,
			},
		},
		default_mappings = true,
		always_exit = true, -- always exit terminal no matter status of previous command
		insert_on_enter = false, -- enter insert mode on entering a terminal
		dependency_commands = {
			make = "makefile",
		},
	}
end

--- replace % with current file name and appends ` && exit || exit` to command
---@param command string the command to append modify
---@param current_file_name string the file name to replace
---@param always_exit boolean whether to always exit terminal. To append ` && exit || exit` to command
function M.replace_filename(command, current_file_name, always_exit)
	if always_exit then
		return string.gsub(command, "%%", current_file_name) .. " && exit || exit"
	else
		return string.gsub(command, "%%", current_file_name) .. " && exit"
	end
end

-- check if current command requires a dependency file
--- check if current command requires a dependency file
---@param command string the command to check
---@param tbl table the list of dependency commands
---@return boolean true if command requires a dependency file, false otherwise
function M.is_dependency(command, tbl)
	for current_command, _ in pairs(tbl) do
		if current_command == command then
			return true
			-- if dependency file is not in cwd,  then return false
			-- if M.validate_cwd_file(dependency) then
			-- return true
			-- else
			-- return false
			-- end
		end
	end
	-- else if command is not a dependency_command, return nil
	return false
end

--- check if a file exists
---@param name string the file name
---@return boolean true if file exists, false otherwise
function M.find_file_in_cwd(name)
	local f = io.open(name, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
	-- local cwd_files = vim.fn.system("ls")

	-- if string.find(cwd_files, string.lower(file_name)) then
	-- return true
	-- else
	-- return false
	-- end
end

return M
