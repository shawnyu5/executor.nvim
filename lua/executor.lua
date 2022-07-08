local M = {}
local settings = {}

local utils = require("utils")

--- opens a terminal in new tab and excute command
--- @param command string the command to execute
local function term_and_excute(command)
	-- get current tab number
	local current_tab = vim.fn.tabpagenr()
	vim.cmd("write")
	vim.cmd("tabe | term")
	-- move terminal to 1 before current tab, so closing terminal will land on the currect page
	vim.cmd("tabm " .. current_tab - 1)
	vim.fn.chansend(vim.b.terminal_job_id, command)
	if settings.insert_on_enter then
		vim.cmd("norm! i")
	end
end

--- sets up executor
---@param user_settings table the settings for executor
function M.setup(user_settings)
	-- if no settings passed in, then set to default values
	if user_settings == nil then
		settings = utils.set_default_values()
	else
		-- else set to settings table passed in
		settings = user_settings
	end

	-- if default mappings, map keys
	if settings.default_mappings then
		vim.keymap.set("n", "<leader>m", require("executor").executor, { silent = false })
		vim.keymap.set("n", "<leader>ct", require("executor").term_closer, { silent = false })
	end
end

-- excutes file based on file type
function M.executor()
	local current_file_name = vim.fn.expand("%")
	-- local current_filetype = vim.bo.filetype
	local current_filetype = vim.api.nvim_buf_get_option(0, "filetype")

	for ft, command_tbl in pairs(settings.commands) do
		if current_filetype == ft then
			-- loop through command table and excute command
			for i = 1, #command_tbl do
				local current_command = command_tbl[i]

				-- check if current command requires a dependency file in cwd, ie `make` -> `makefile`
				if not utils.is_dependency(current_command, settings.dependency_commands) then
					-- if dependency not found, skip command
					goto continue
				end

				-- if extern, execute command in external terminal
				if command_tbl.extern == false then
					vim.cmd(current_command)
					-- stop after command has been excuted
					return
				else
					current_command = utils.replace_filename(current_command, current_file_name, settings.always_exit)
					term_and_excute(current_command .. "\n")
					return
				end
				::continue::
			end
			-- if command is excuted, for loop should not finish. Only when there
			-- are no commands defined for current filetype the forloop exits.
			vim.notify("No mapping defined for current file type", vim.log.levels.WARN)
		end
	end
end

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
