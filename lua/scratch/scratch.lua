local i, t, popen = 0, {}, io.popen
local pfile = popen('ls -a')
for filename in pfile:lines() do
    i = i + 1
    t[i] = filename
end
pfile:close()
print(vim.inspect(t))
