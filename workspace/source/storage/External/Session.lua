local manager = _G.Manager

-- Manager Modules
local datastore = manager('Datastore')
local cache = manager('Cache'):Create('Sessions')

-- Services
local replicated_storage = game:GetService('ReplicatedStorage')

-- Folders
local remotes = replicated_storage.Remotes
local common = replicated_storage.Common

-- Remotes
local render = remotes.Render
local session_update = remotes.SessionUpdate
local data_update = remotes.DataUpdate

-- Modules
local signal = require(common.Signal)

-- Main Module
local session = {}
session.__index = session

function session:Start()
	self.isActive = true
	self.State = 'Playing'
	self.Status = 'Game is in progress!'
	session_update:FireClient(self.Player, self:Filter())
end

function session:Play()
	if (self.State ~= 'Playing' or not self.isActive and (self.Cooldown == 0 or os.time() > self.Cooldown)) then return end
	self.Cooldown = os.time() + .4

	-- Variables
	local reduce_chance = self.Data.Reduce_Fall_Chance
	local extra_brick_chance = self.Data.Extra_Brick_Chance

	self.Signal:Fire('Brick')

	-- Apply reduce chance
	if ((math.random() - reduce_chance) < reduce_chance) then
		self.Chance += math.random(1, 5)
	end

	-- Check if player gets extra brick
	if ((math.random() - extra_brick_chance) > extra_brick_chance) then
		self.Signal:Fire('Brick')
	end

	session_update:FireClient(self.Player, self:Filter())

	if (math.floor(self.Chance) >= 100) then
		self:Finish()
	end
end

function session:Finish()
	self.State = 'Inactive'
	self.Chance = 0
	self.Height = 0
	self.isActive = false

	self.Signal:Fire('Cleanup')

	session_update:FireClient(self.Player, self:Filter())
end

function session:Filter()
	-- This method filters session data for the client to use.
	local whitelist = { 'chance', 'height', 'status', 'state' }
	local copied = {}

	for k, v in next, self do
		if (table.find(whitelist, k:lower())) then
			copied[k] = v
		end
	end

	return copied
end

function session:Upgrade(enum: number)
	if (typeof(enum) ~= 'number') then return end

	local upgrade = ({ 'Reduce_Fall_Chance', 'Extra_Brick_Chance', 'Brick_Multiplier' })[enum]

	-- Sanity Check
	if (not upgrade) then
		return
	end

	local upgrade_cost = self.Data.Prices[upgrade]

	local formulas = {
		Reduce_Fall_Chance = function(price: number, value: number)
			self.Data.Prices[upgrade] = math.floor((value + price) * 1.4)
			self.Data[upgrade] -= math.clamp(math.abs(value / 10), 0, 1)
		end,
		Extra_Brick_Chance = function(price: number, value: number)
			self.Data.Prices[upgrade] = math.floor((value + price) * 1.8)
			self.Data[upgrade] -= math.clamp(math.abs(value / 10), 0, 1)
		end,
		Brick_Multiplier = function(price: number, value: number)
			self.Data.Prices[upgrade] = math.floor((value + price) * 1.2)
			self.Data[upgrade] += ((self.Data.Prices[upgrade] / (self.Data[upgrade] * 10)) * .05)
		end
	}

	if (self.Data.Bricks >= upgrade_cost) then
		if (not formulas[upgrade]) then return end

		self.Data.Bricks -= upgrade_cost --> Remove the players "bricks"

		formulas[upgrade](upgrade_cost, self.Data[upgrade])
		session_update:FireClient(self.Player, self:Filter())
		data_update:FireClient(self.Player, datastore.Filter(self.Player.UserId))
	end
end

return {
	New = function(player: Instance)
		local puid = player.UserId
		local data = datastore.Fetch(puid).Data

		if (cache:IsEntry(puid) or not data) then
			return
		end

		local self = {}
		self.isActive = true
		self.State = 'Inactive'
		self.Status = 'Ready!'
		self.Height = 0
		self.Chance = 0
		self.Data = data
		self.Player = player
		self.Signal = signal.New()
		self.Cooldown = 0

		self.Signal:Connect(function(render_item)
			render:FireClient(self.Player, render_item)

			if (render_item == 'Brick') then
				self.Height += 1
				self.Data.Bricks += 1 * self.Data.Brick_Multiplier

				-- Extra sanity check
				if (self.Data.HighestStack < self.Height) then
					self.Data.HighestStack = self.Height
				end

				session_update:FireClient(self.Player, self:Filter())
				data_update:FireClient(self.Player, datastore.Filter(self.Player.UserId))
			end
		end)

		setmetatable(self, session)

		cache:Add(puid, self)
		return self
	end
}