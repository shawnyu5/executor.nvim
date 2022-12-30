local M = {}

---@class ExecutorOptions
---@field commands table commands for each filetype
---@field default_mappings boolean weather to define default mappings
---@field always_exit boolean always append `|| exit` to command
---@field insert_on_enter boolean enter insert mode when spawning a new terminal
---@field dependency_commands table commands that require a dependency file
M.default_opts = {
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

--- check if current command requires a dependency file
---@param command string the command to check
---@param tbl table the list of dependency commands
---@return boolean true if command requires a dependency file, false otherwise
function M.is_dependency(command, tbl)
	if tbl[command] ~= nil then
		return true
	end
	return false
end

--- check if a file exists
---@param name string the file name
---@return boolean true if file exists in pwd, false otherwise
function M.find_file_in_cwd(name)
	local f = io.open(name, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

return M
