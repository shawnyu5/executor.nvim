local executor = require("executor")
local utils = require("utils")

describe("executor", function()
	it("should return a default table", function()
		local default_settings = utils.set_default_values()
		local default_table = {
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
			always_exit = true, -- always exit terminal no matter status of previous
			dependency_commands = {
				make = "makefile",
			},
		}
		assert.are.same(default_settings, default_table)
	end)
end)

describe("utils", function()
	it("Should be a dependency command", function()
		local is_dependency = utils.is_dependency("make", { make = "makefile" })
		assert.is_true(is_dependency)
	end)

	it("Should be not be a dependency command", function()
		local is_dependency = utils.is_dependency("make", { apple = "makefile" })
		assert.is_false(is_dependency)
	end)

	it("Should find current file", function()
		local found = utils.validate_cwd_file("lua/tests/executor_spec.lua")
		assert.is_true(found)
	end)

	it("Should not find current file", function()
		local found = utils.validate_cwd_file("lua/tests/executor_spec.lua.not")
		assert.is_false(found)
	end)

	it("Should replace % with file name, always_exit = false", function()
		local command = utils.replace_filename("g++ % && ./a.out", "a.cpp", false)
		assert.are.equal("g++ a.cpp && ./a.out && exit", command)
	end)

	it("Should replace % with file name, always_exit = true", function()
		local command = utils.replace_filename("g++ % && ./a.out", "a.cpp", true)
		assert.are.equal("g++ a.cpp && ./a.out && exit || exit", command)
	end)
end)

describe("term closer", function()
	it("should delete all terminal buffers, in the case that they do exist", function()
		for _ = 1, 4 do
			local buf = vim.api.nvim_create_buf(true, false)
			vim.api.nvim_buf_set_option(buf, "buftype", "terminal")
		end

		for _ = 1, 4 do
			vim.api.nvim_create_buf(true, false)
		end
		executor.term_closer()

		local bufs = vim.api.nvim_list_bufs()

		-- go through all buffers, there should be no terminal buffers
		for _, buffer in ipairs(bufs) do
			local buftype = vim.api.nvim_buf_get_option(buffer, "buftype")
			assert.are_not.equal("terminal", buftype)
		end
	end)
end)
