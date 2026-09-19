--[[
  STEAL AN EGG v7 loader | Jayren Hub
  EggState + Assets rarity | corridor move | Rayfield Gen2
  Cosmic Secret > Eternal > Divine

  loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/barnesjayren0-sudo/Jayren-Sudo-Rivals-Hub@main/scripts/StealAnEgg.lua"))()
]]
local base = "https://raw.githubusercontent.com/barnesjayren0-sudo/Jayren-Sudo-Rivals-Hub/main/scripts/"
local chunks = {}
for i = 0, 2 do
	local ok, body = pcall(function()
		return game:HttpGet(base .. "StealAnEgg_p" .. i .. ".lua")
	end)
	if not ok or not body or #body < 10 then
		error("Failed to load StealAnEgg part " .. i)
	end
	table.insert(chunks, body)
end
local src = table.concat(chunks)
local fn, err = loadstring(src)
if not fn then
	error(err)
end
fn()
