-- I wrote this because I don't like UI variable spam in normal scripts :)
local players = game:GetService('Players')
local player = players.LocalPlayer
local player_gui = player:WaitForChild('PlayerGui')

-- UI Elements
local v1 = player_gui:WaitForChild('MainUI')
local v2 = v1.ShopFrame
local v3 = v1.Status.Inner
local v4 = v1.Height.Inner
local v5 = v1.Chance.Inner
local v6 = v1.Record.Inner
local v7 = v1.Control
local v8 = v1.Epic
local v9 = v1.Shop
local v10 = v2.ReduceFallChance
local v11 = v2.ExtraBrickChance
local v12 = v2.Multiplier
local v13 = v1.Bricks
local v14 = v1.Notification.Inner

return {
	main = v1,
	shop_frame = v2,
	status = v3,
	height = v4,
	chance = v5,
	record = v6,
	control = v7,
	epic_sound = v8,
	shop = v9,
	reduce_fall_chance = v10,
	extra_brick_chance = v11,
	brick_multiplier = v12,
	bricks = v13,
	notification = v14
}