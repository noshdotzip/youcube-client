--[[
_ _  _ ____ ___ ____ _    _    ____ ____
| |\ | [__   |  |__| |    |    |___ |__/
| | \| ___]  |  |  | |___ |___ |___ |  \

Github Repository: https://github.com/noshdotzip/youcube-client
License: GPL-3.0
]]
-- OpenInstaller v1.0.0 (based on wget)

local REPO_RAW_BASE = "https://raw.githubusercontent.com/noshdotzip/youcube-client/main/"
local BASE_URL = REPO_RAW_BASE .. "src/"

local files = {
    ["./youcube.lua"] = BASE_URL .. "youcube.lua",
    ["./lib/youcubeapi.lua"] = BASE_URL .. "lib/youcubeapi.lua",
    ["./lib/numberformatter.lua"] = BASE_URL .. "lib/numberformatter.lua",
    ["./lib/semver.lua"] = BASE_URL .. "lib/semver.lua",
    ["./lib/argparse.lua"] = BASE_URL .. "lib/argparse.lua",
    ["./lib/string_pack.lua"] = BASE_URL .. "lib/string_pack.lua",
}

if not http then
    printError("OpenInstaller requires the http API")
    printError("Set http.enabled to true in the ComputerCraft config")
    return
end

local extra_files = {
    "/.youcube_server",
    "/youcube_server.txt",
    "/youcube",
}

local function is_installed()
    for path, _ in pairs(files) do
        local resolved_path = shell.resolve(path)
        if fs.exists(resolved_path) then
            return true
        end
    end
    for _, path in pairs(extra_files) do
        if fs.exists(path) then
            return true
        end
    end
    return false
end

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

    -- Reset colour
    term.setTextColour(previous_colour)

    local input_char = read():sub(1, 1):lower()
    local accept_chars = { "o", "k", "y", "j", "" }

    if tableContains(accept_chars, input_char) then
        return true
    end

    return false
end

local unknown_error = "Unknown error"

local function http_get(url)
    local valid_url, error_message = http.checkURL(url)
    if not valid_url then
        printError(('"%s" %s.'):format(url, error_message or "Invalid URL"))
        return
    end

    local response, http_error_message = http.get(url, nil, true)
    if not response then
        printError(('Failed to download "%s" (%s).'):format(url, http_error_message or unknown_error))
        return
    end

    local response_body = response.readAll()
    response.close()

    if not response_body then
        printError(('Failed to download "%s" (Empty response).'):format(url))
    end

    return response_body
end

local function remove_installation()
    local removed = false
    for path, _ in pairs(files) do
        local resolved_path = shell.resolve(path)
        if fs.exists(resolved_path) then
            fs.delete(resolved_path)
            term.setTextColour(colors.lime)
            print(('Deleted "%s"'):format(path))
            removed = true
        end
    end

    for _, path in pairs(extra_files) do
        if fs.exists(path) then
            fs.delete(path)
            term.setTextColour(colors.lime)
            print(('Deleted "%s"'):format(path))
            removed = true
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

    if not removed then
        term.setTextColour(colors.yellow)
        print("No installed files found.")
    end
    term.setTextColour(colors.white)
end

local function prompt_action()
    term.setTextColour(colors.white)
    print("YouCube is already installed. Choose an action:")
    print("1. Cancel")
    print("2. Update")
    print("3. Remove")
    term.setTextColour(colors.lightGray)
    local choice = read()
    term.setTextColour(colors.white)
    return choice
end

local always_override = false
if is_installed() then
    local action = prompt_action()
    if action == "1" or action == "cancel" then
        return
    elseif action == "3" or action == "remove" then
        if question("Remove YouCube files") then
            remove_installation()
        end
        return
    else
        always_override = true
    end
end

for path, download_url in pairs(files) do
    local resolved_path = shell.resolve(path)
    if fs.exists(resolved_path) and not always_override then
        if not question(('"%s" already exists. Override'):format(path)) then
            return
        end
    end

    local response_body = http_get(download_url)

    local file, file_open_error_message = fs.open(resolved_path, "wb")
    if not file then
        printError(('Failed to save "%s" (%s).'):format(path, file_open_error_message or unknown_error))
        return
    end

    file.write(response_body)
    file.close()

    term.setTextColour(colors.lime)
    print(('Downloaded "%s"'):format(path))
end

local function ask_server_url()
    term.setTextColour(colors.white)
    print("Enter your YouCube server URL (leave blank to skip):")
    term.setTextColour(colors.lightGray)
    local input = read()
    term.setTextColour(colors.white)
    if input and input:gsub("%s+", "") ~= "" then
        return input
    end
    return nil
end

local function save_server_url(server_url)
    if settings and settings.set then
        settings.set("youcube.server", server_url)
        if settings.save then
            settings.save()
        end
        print('Saved settings "youcube.server"')
    end

    local file_path = "/.youcube_server"
    local file, file_open_error_message = fs.open(file_path, "w")
    if not file then
        printError(('Failed to save "%s" (%s).'):format(file_path, file_open_error_message or unknown_error))
        return false
    end
    file.write(server_url)
    file.close()
    term.setTextColour(colors.lime)
    print(('Saved "%s"'):format(file_path))
    return true
end

local function resolve_launcher_target()
    return shell.resolve("./youcube.lua")
end

local function ensure_launcher()
    local target = resolve_launcher_target()
    local launcher_path = "/youcube"
    local file, err = fs.open(launcher_path, "w")
    if not file then
        printError(('Failed to write "%s" (%s).'):format(launcher_path, err or unknown_error))
        return
    end
    file.write("local target = " .. textutils.serialise(target) .. "\n")
    file.write("if fs.exists(target) then\n")
    file.write("  shell.run(target, ...)\n")
    file.write("else\n")
    file.write("  print(\"YouCube not found at \" .. target)\n")
    file.write("end\n")
    file.close()
    term.setTextColour(colors.lime)
    print(('Installed launcher "%s"'):format(launcher_path))
end

local function ensure_server_config()
    local file_path = "/.youcube_server"
    local server_url = nil
    if fs.exists(file_path) then
        local file = fs.open(file_path, "r")
        if file then
            local value = file.readAll()
            file.close()
            if value and value:gsub("%s+", "") ~= "" then
                server_url = value:gsub("^%s+", ""):gsub("%s+$", "")
            end
        end
    end

    if not server_url then
        server_url = ask_server_url()
    end

    if server_url then
        save_server_url(server_url)
    else
        term.setTextColour(colors.yellow)
        print("No server URL configured. You can set it later with:")
        print('settings.set("youcube.server", "wss://your.server:5000")')
        print('or by writing it to "/.youcube_server"')
        term.setTextColour(colors.white)
    end
end

ensure_launcher()
ensure_server_config()
