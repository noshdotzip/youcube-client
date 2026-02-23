--[[
_ _  _ ____ ___ ____ _    _    ____ ____
| |\ | [__   |  |__| |    |    |___ |__/
| | \| ___]  |  |  | |___ |___ |___ |  \

Github Repository: https://github.com/noshdotzip/youcube-client
License: GPL-3.0
]]
-- YouCube Cleanup Script

local files = {
    "./youcube.lua",
    "./lib/youcubeapi.lua",
    "./lib/numberformatter.lua",
    "./lib/semver.lua",
    "./lib/argparse.lua",
    "./lib/string_pack.lua",
}

local function tableContains(_table, element)
    for _, value in pairs(_table) do
        if value == element then
            return true
        end
    end
    return false
end

local function writeColoured(text, colour)
    term.setTextColour(colour)
    term.write(text)
end

local function question(message)
    local previous_colour = term.getTextColour()

    writeColoured(message .. "? [", colors.orange)
    writeColoured("Y", colors.lime)
    writeColoured("/", colors.orange)
    writeColoured("n", colors.red)
    writeColoured("] ", colors.orange)

    term.setTextColour(previous_colour)

    local input_char = read():sub(1, 1):lower()
    local accept_chars = { "o", "k", "y", "j", "" }

    return tableContains(accept_chars, input_char)
end

if not question("Delete YouCube files") then
    return
end

for _, path in pairs(files) do
    local resolved_path = shell.resolve(path)
    if fs.exists(resolved_path) then
        fs.delete(resolved_path)
        term.setTextColour(colors.lime)
        print(('Deleted "%s"'):format(path))
    end
end

local lib_path = shell.resolve("./lib")
if fs.exists(lib_path) then
    local contents = fs.list(lib_path)
    if #contents == 0 then
        fs.delete(lib_path)
        term.setTextColour(colors.lime)
        print('Deleted "./lib"')
    end
end

term.setTextColour(colors.white)
print("Cleanup complete")
