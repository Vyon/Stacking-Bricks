local server_settings = { isDebug = true }

-- Datastore
server_settings.Datastore = {
	name = 'ds@test',
	blacklist = { 'transactions', 'claimed', 'reducechance', 'extrabrickchance', 'brickmultiplier' },
	template = {
		Bricks = 0,
		Claimed = 0,
		Streak = 0,
		HighestStack = 0,
		Reduce_Fall_Chance = 1,
		Extra_Brick_Chance = 1,
		Brick_Multiplier = 1,
		Prices = {
			Reduce_Fall_Chance = 30,
			Extra_Brick_Chance = 130,
			Brick_Multiplier = 75
		}
	}
}

return server_settings