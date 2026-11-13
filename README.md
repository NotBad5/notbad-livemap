# notbad-livemap

A live map of your FiveM server in the browser. It shows where every player is, updated every couple of seconds.

## Features
- Runs on your normal server port: **no extra port, no yarn, no npm, no dependencies**
- Optional **password**, with a lockout after repeated wrong guesses
- Player list with search. Click a player to follow them on the map
- Markers show the direction a player is facing and whether they are on foot or in a vehicle
- Drag and zoom with mouse or touch, works on phones
- Game coordinates under the cursor, click the map to copy them
- Player count in the browser tab, ping in the player list
- Hide players with a simple config function (staff, undercover units...)
- Positions are only collected while somebody has the map open

## Install
1. Put the `notbad-livemap` folder in your `resources` directory.
2. Add `ensure notbad-livemap` to `server.cfg`.
3. Set a password in `config.lua`.
4. Open `http://YOUR_SERVER_IP:30120/notbad-livemap/` (use your own server port if it is not 30120).

Requires OneSync, which is on by default on current servers.

## Config
| Option | What it does |
|---|---|
| `Config.Password` | Password for the map. Empty means anyone with the link can see it |
| `Config.Title` | Name shown on the page |
| `Config.UpdateInterval` | Refresh rate in milliseconds |
| `Config.ShowNames` | Show player names, or only server IDs |
| `Config.ShowPing` | Show each player's ping in the list |
| `Config.ShouldShow` | Function that returns `false` to hide a player |
| `Config.MapImage` | URL of the map picture |
| `Config.Calibration` | How game coordinates map to the picture, only needed for a different image |

## Using your own map picture
1. Put the URL of your picture in `Config.MapImage` and restart the resource. Any size or shape works.
2. Open the map with `?calibrate` at the end of the address: `http://YOUR_SERVER_IP:30120/notbad-livemap/?calibrate`
3. For each place, choose a player in the list (their current position is used, so ask them to stand still) or type game coordinates yourself. Then click that exact spot on the picture.
4. After two places the players on the map jump to the new alignment so you can check it. A third place tells you how well it fits.
5. Press **Copy for config.lua**, paste the block over `Config.Calibration` in `config.lua`, and restart the resource.

Pick places that are far apart, for example one in the city and one up north. The picture must be a straight top-down map with north at the top.

## Upgrading from 1.0
- Delete the old folder first. `config.json`, `server.js`, `package.json` and `node_modules` are gone.
- The address changed from `http://IP:3000/` to `http://IP:30120/notbad-livemap/`. You can close port 3000.
- The `yarn` resource is no longer needed for this script.

## Good to know
- The connection is plain HTTP, so the password is not encrypted on the way. Do not reuse an important password.
- The map picture is loaded from the URL in `Config.MapImage`. Host the image yourself if you want to be sure it never disappears.
- If you rename the resource folder, the address changes with it.
