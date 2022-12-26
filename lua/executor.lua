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
---@param opts table the settings for executor
function M.setup(opts)
	-- if no settings passed in, then set to default values
	settings = vim.tbl_deep_extend("force", utils.default_opts(), opts or {})

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

				-- check if current command requires a dependency file in cwd, ie
				-- `make` -> `makefile`. And the dependency file does not exist,
				-- skip this command
				if
					utils.is_dependency(current_command, settings.dependency_commands)
					and not utils.find_file_in_cwd(settings.dependency_commands[current_command])
				then
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
	local buffers = vim.api.nvim_list_bufs()
	-- loop through all buffers
	for _, buffer in ipairs(buffers) do
		local buf_type = vim.api.nvim_buf_get_option(buffer, "buftype")
		-- if its a terminal buffer, force delete it, without regard for unsaved changes
		if buf_type == "terminal" then
			vim.api.nvim_buf_delete(buffer, { force = true })
		end
	end
end

return M
