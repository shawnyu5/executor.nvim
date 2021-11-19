local M = {}

local tbl = {
    names = {
        person1 = "john",
        person2 = "shawn"
    }
}

local function names()
    return tbl.names
end

local nested = names()

print("og table", vim.inspect(tbl))
print("names table", vim.inspect(nested))
nested.person1 = "random person"

print("person 1 modified")

print("og table", vim.inspect(tbl))
print("names table", vim.inspect(nested))

return M
