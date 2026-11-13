-- notbad-livemap: serves the map through FiveM's built-in HTTP handler.
-- URL: http://<server ip>:<server port>/<resource name>/

local RESOURCE = GetCurrentResourceName()
local page = LoadResourceFile(RESOURCE, 'web/index.html')

local cache, cacheAt = nil, -1000000
local failed = {}   -- wrong password attempts per address

local MAX_ATTEMPTS = 8
local LOCK_SECONDS = 60

local function round(n)
    return math.floor(n * 10 + 0.5) / 10
end

local function passwordSet()
    return type(Config.Password) == 'string' and Config.Password ~= ''
end

local function shouldShow(src)
    if type(Config.ShouldShow) ~= 'function' then return true end
    local ok, result = pcall(Config.ShouldShow, tonumber(src))
    return not ok or result ~= false
end

local function snapshot()
    local now = GetGameTimer()
    if cache and now - cacheAt < Config.UpdateInterval then
        return cache
    end

    local players = {}
    for _, src in ipairs(GetPlayers()) do
        local ped = GetPlayerPed(src)
        if ped and ped ~= 0 and DoesEntityExist(ped) and shouldShow(src) then
            local coords = GetEntityCoords(ped)
            players[#players + 1] = {
                id = tonumber(src),
                name = Config.ShowNames and GetPlayerName(src) or nil,
                x = round(coords.x),
                y = round(coords.y),
                h = math.floor(GetEntityHeading(ped) + 0.5),
                v = GetVehiclePedIsIn(ped, false) ~= 0,
                ping = Config.ShowPing and GetPlayerPing(src) or nil,
            }
        end
    end

    cache = json.encode({
        players = players,
        count = #players,
        max = GetConvarInt('sv_maxclients', 48),
    })
    cacheAt = now
    return cache
end

local function header(request, name)
    for key, value in pairs(request.headers or {}) do
        if key:lower() == name then return value end
    end
end

local function address(request)
    local addr = tostring(request.address or '?')
    return addr:match('^%[(.+)%]:%d+$') or addr:match('^([^:]+):%d+$') or addr
end

-- returns: allowed (bool), status code when not allowed
local function authorize(request)
    if not passwordSet() then return true end

    local addr = address(request)
    local entry = failed[addr]
    local now = os.time()

    if entry and entry.count >= MAX_ATTEMPTS then
        if now < entry.lockedUntil then return false, 429 end
        failed[addr] = nil
        entry = nil
    end

    if header(request, 'x-livemap-key') == Config.Password then
        failed[addr] = nil
        return true
    end

    -- a missing key is just the login screen asking; only count real guesses
    if header(request, 'x-livemap-key') then
        entry = entry or { count = 0, lockedUntil = 0 }
        entry.count = entry.count + 1
        entry.lockedUntil = now + LOCK_SECONDS
        failed[addr] = entry
    end
    return false, 401
end

local function send(response, code, contentType, body)
    response.writeHead(code, {
        ['Content-Type'] = contentType,
        ['Cache-Control'] = 'no-store',
        ['X-Content-Type-Options'] = 'nosniff',
    })
    response.send(body)
end

local function renderPage()
    local settings = json.encode({
        title = Config.Title,
        mapImage = Config.MapImage,
        calibration = Config.Calibration,
        interval = Config.UpdateInterval,
        password = passwordSet(),
    }):gsub('<', '\\u003c')

    return (page:gsub('__LIVEMAP_CONFIG__', function() return settings end))
end

SetHttpHandler(function(request, response)
    local path = (request.path or '/'):gsub('%?.*$', '')

    if request.method ~= 'GET' then
        return send(response, 405, 'text/plain', 'Method not allowed')
    end

    if path == '/' or path == '' or path == '/index.html' then
        if not page then
            return send(response, 500, 'text/plain', 'web/index.html is missing from the resource')
        end
        return send(response, 200, 'text/html; charset=utf-8', renderPage())
    end

    if path == '/players' then
        local allowed, code = authorize(request)
        if not allowed then
            return send(response, code, 'application/json', '{"error":"' .. (code == 429 and 'locked' or 'password') .. '"}')
        end
        return send(response, 200, 'application/json', snapshot())
    end

    send(response, 404, 'text/plain', 'Not found')
end)

CreateThread(function()
    Wait(1000)
    local port = GetConvar('netPort', '30120')
    print(('^2[%s]^7 Live map: http://<your server ip>:%s/%s/'):format(RESOURCE, port, RESOURCE))
    if not passwordSet() then
        print(('^3[%s]^7 No password set. Anyone with the link can see where your players are. Set Config.Password in config.lua.'):format(RESOURCE))
    end
end)
