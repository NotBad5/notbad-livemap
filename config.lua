Config = {}

-- Shown in the browser tab and at the top of the player list.
Config.Title = 'Live map'

-- Password for the map. Anyone who knows it can see every player's position,
-- so set one unless the map is meant to be public. '' = no password.
Config.Password = ''

-- How often player positions are refreshed, in milliseconds.
-- Positions are only collected while somebody has the map open.
Config.UpdateInterval = 2000

-- Show player names. With false the map only shows server IDs.
Config.ShowNames = true

-- Show each player's ping in the player list.
Config.ShowPing = true

-- Return false to hide a player from the map (staff, undercover units...).
-- source is the player's server ID.
Config.ShouldShow = function(source)
    return true
end

-- The map picture. Any image URL works. Hosting it yourself is the safest choice:
-- if this link ever stops working the map shows players on an empty background.
Config.MapImage = 'https://imgur.com/kTRQ3mF.png'

-- How game coordinates land on the picture. Only change this if you use a different image.
-- You do not have to work these numbers out by hand: open the map with ?calibrate at the end
-- of the address, mark two or three places, and paste the block it gives you over this one.
-- size:  width of the image in pixels
-- zeroX, zeroY: pixel position of game coordinate 0, 0
-- scale: game units per pixel
Config.Calibration = {
    size  = 4096,
    zeroX = 1877.25,
    zeroY = 2765,
    scale = 3.037861303705727,
}
