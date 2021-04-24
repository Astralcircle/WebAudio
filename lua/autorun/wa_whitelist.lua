


-- Match, IsPattern
local function pattern(str) return { str, true } end
local function simple(str) return { str, false } end

local registers = { ["pattern"] = pattern, ["simple"] = simple }

-- Inspired / Taken from StarfallEx & Metastruct/gurl
-- No blacklist for now, just don't whitelist anything that has weird other routes.

--- Note #1 (For PR Help)
-- Sites cannot track users / do any scummy shit with your data unless they're a massive corporation that you really can't avoid anyways.
-- So don't think about PRing your own website
-- Also these have to do with audio since this is a audio addon.

--- Note #2
-- Create a file called webaudio_whitelist.txt in your data folder to overwrite this, works on the server box or on your client.
local Whitelist = {
    -- Soundcloud
    pattern [[%w+%.sndcdn%.com]],

    -- Google Translate Api
    simple [[translate.google.com]],

    -- Discord
    pattern [[cdn[%w-_]*.discordapp%.com]],

    -- Reddit
    simple [[i.redditmedia.com]],
    simple [[i.redd.it]],
    simple [[preview.redd.it]],

    -- Shoutcast
    simple [[yp.shoutcast.com]],

    -- Dropbox
    simple [[dl.dropboxusercontent.com]],
    pattern [[%w+%.dl%.dropboxusercontent%.com/(.+)]],
    simple [[www.dropbox.com]],
    simple [[dl.dropbox.com]],
}

if file.Exists("webaudio_whitelist.txt", "DATA") then
    local dat = file.Read("webaudio_whitelist.txt", "DATA")
    local new_list, ind = {}, 0
    for line in dat:gmatch("[^\n]+") do
        local type, match = line:match("(%w+)%s+(.*)")
        local reg = registers[type]
        if reg then
            new_list[ind] = registers[type](match)
            ind = ind + 1
        elseif type ~= nil then
            -- Make sure type isn't nil so we ignore empty lines
            warn("Invalid entry type found [\"", type, "\"] in webaudio_whitelist\n")
        end
    end
    print("Whitelist from webaudio_whitelist.txt found and parsed with " .. ind .. " entries!")
    Whitelist = new_list
end

local function isWhitelistedURL(url)
    local relative = url:match("https?://(.*)")
    if not relative then return false end
    for k, v in ipairs(Whitelist) do
        local haystack = v[2] and relative or (relative:match("(.-)/.*") or relative)
        local res = haystack:find( string.format("^%s%s", v[1], is_pattern and "" or "$") )
        if res then return true end
    end
    return false
end

return {
    isWhitelistedURL = isWhitelistedURL,
    Whitelist = Whitelist
}