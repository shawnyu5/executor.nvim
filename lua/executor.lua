local M = {}

---@class ExecutorOptions
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
	settings = vim.tbl_deep_extend("force", utils.default_opts, opts or {})

	-- if default mappings, map keys
	if settings.default_mappings then
		vim.keymap.set("n", "<leader>m", require("executor").executor, { silent = false })
		vim.keymap.set("n", "<leader>ct", require("executor").term_closer, { silent = false })
	end
end

-- runs a command based on the file type
function M.executor()
	local file_name = vim.fn.expand("%")
	local ft = vim.api.nvim_buf_get_option(0, "filetype")

	---@type table
	local commandTbl = settings.commands[ft]
	for _, command in pairs(commandTbl) do
		if
			utils.is_dependency(command, settings.dependency_commands)
			and not utils.find_file_in_cwd(settings.dependency_commands[command])
		then
			goto continue
		end

		-- if not external terminal, run command as a vim command
		if commandTbl.extern == false then
			vim.notify(command)
			vim.cmd(command)
			-- stop after command has been excuted
			return
		else
			-- spawn a terminal and run command
			command = utils.replace_filename(command, file_name, settings.always_exit)
			term_and_excute(command .. "\n")
			return
		end
		::continue::
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
