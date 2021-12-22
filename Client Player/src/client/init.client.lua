-- Services
local players = game:GetService('Players')
local tween_service = game:GetService('TweenService')
local lighting = game:GetService('Lighting')

-- Player Info
local player = players.LocalPlayer
local player_gui = player:WaitForChild('PlayerGui')
local camera = workspace.CurrentCamera

-- UI Elements
local main = player_gui:WaitForChild('MainUI')
local shop_frame = main.ShopFrame
local status = main.Status.Inner
local height = main.Height.Inner
local chance = main.Chance.Inner
local best = main.Best.Inner
local control = main.Control
local epic = main.Epic
local shop = main.Shop
local reduce_chance = shop_frame.ReduceFallChance
local extra_stack_chance = shop_frame.ExtraStackChance
local brick_multiplier = shop_frame.Multiplier
local earned_label = main.Earned

-- Locals
local parts = Instance.new('Folder', workspace); parts.Name = 'Parts'

-- Modules
local signal = require(script.Signal)
local sounds = require(script.Sounds)
local suffix = require(script.Suffix)

-- Variables
local is_tweening = false
local shop_toggled = false
local isAlive = true

-- Tables
local shop_costs = { reduce = 30, stack = 130, multiplier = 75 }

-- Private Functions
local function CreatePart(self)
	local part = Instance.new('Part', parts)
	part.Name = ''
	part.BrickColor = BrickColor.Random()
	part.Anchored = true
	part.Position = Vector3.new(0, (part.Size.Y * #parts:GetChildren()))
	part.CastShadow = false

	local info = TweenInfo.new(.2, Enum.EasingStyle.Linear)

	local destination = part.CFrame * CFrame.new(6, 1.5, 10) * CFrame.fromEulerAnglesXYZ(0, .3, 0)

	sounds.Build()

	local tween = tween_service:Create(camera, info, { CFrame = destination })
	tween:Play()

	self.Earned += 1 * self.Multiplier
	self('Earned'):Fire()
end

local game_object = (function()
	local private = {}
	private.__index = private

	function private:__call(key)
		return self.Signals[key]
	end

	function private:Start()
		if (self.Ending) then return end

		status.Text = 'Game is starting...'

		task.wait(1)

		if (self.State == 'Inactive') then
			self.State = 'Active'
			self.Signals.Starting:Fire()
		end
	end

	function private:Play()
		if (self.State ~= 'Active' or self.Ending) then return end

		CreatePart(self)
		self.Height += 1

		-- Fall chance reduction
		if ((math.random() - self.Reduce) < self.Reduce) then
			self.Chance += math.random(10, 50) / 10
		end

		-- Chance to get an extra brick
		if ((math.random() - self.Extra) > self.Extra) then
			CreatePart(self)
			self.Height += 1
		end

		self('Height'):Fire()
		self('Chance'):Fire()

		if (self.Chance > 100) then
			self:End()
		end
	end

	function private:End()
		self.State = 'Inactive'
		self.StartingIn = 3
		self.Chance = 0
		self.Ending = true

		local destination = CFrame.new(6, 1.5, 10) * CFrame.fromEulerAnglesXYZ(0, .3, 0)
		camera.CameraType = Enum.CameraType.Scriptable
		local tween = tween_service:Create(
			camera,
			TweenInfo.new(
				#parts:GetChildren() / 100,
				Enum.EasingStyle.Linear
			),
			{ CFrame = destination }
		)
		tween:Play()

		for i = #parts:GetChildren(), 1, -1 do
			local part = parts:GetChildren()[i]

			part:Destroy()
		end

		tween.Completed:Wait()

		-- Finalize stat updates
		self.Height = 0
		self('Height'):Fire(true)
		self('Chance'):Fire()
		self('Ending'):Fire()
	end

	function private:Runtime()
		print(string.format('%.1f Minutes', (tick() - self.Timestamp) / 60))
	end

	local function Constructor()
		local self = {}
		self.State = 'Inactive'
		self.Height = 0
		self.Timestamp = tick()
		self.Chance = 0
		self.Best = 0
		self.StartingIn = 0
		self.Earned = 0
		self.Signals = {}
		self.Ending = false
		self.Reduce = 1 --> 1 is representing 0% chance to get fall chance reduced
		self.Extra = 1 --> 1 is representing 0% chance to get extra stack chance reduced
		self.Multiplier = 1

		-- Setup Signals
		do
			self.Signals['Starting'] = signal.New()
			self.Signals['Ending'] = signal.New()
			self.Signals['Height'] = signal.New()
			self.Signals['Chance'] = signal.New()
			self.Signals['Earned'] = signal.New()
		end

		return self
	end

	return setmetatable(Constructor(), private)
end)()

-- Set Label Values
earned_label.Text = 'Bricks: ' .. suffix(game_object.Earned)
reduce_chance.Text = string.format('Reduce Fall Chance: <font color="rgb(255, 179, 2)">%s</font>', suffix(shop_costs.reduce))
extra_stack_chance.Text = string.format('Extra Stack Chance: <font color="rgb(255, 179, 2)">%s</font>', suffix(shop_costs.stack))
brick_multiplier.Text = string.format('Brick Multiplier: <font color="rgb(255, 179, 2)">%s</font>', suffix(shop_costs.multiplier))

-- Game EventListeners
game_object('Starting'):Connect(function()
	status.Text = 'Game in progress'
end)

game_object('Ending'):Connect(function()
	game_object.Ending = false
	control.Text = 'Start!'
	status.Text = 'Ready!'
end)

game_object('Height'):Connect(function(ending)
	local stack_height = game_object.Height

	height.Text = string.format('Stack height: %d', stack_height)

	if (stack_height > game_object.Best) then
		game_object.Best = stack_height
		best.Text = string.format('Highest stack: %d', stack_height)
	else
		best.Text = string.format('Highest stack: %d', game_object.Best)
	end
end)

game_object('Chance'):Connect(function()
	chance.Text = string.format('Chance to fall: %.1f%%', game_object.Chance)
end)

game_object('Earned'):Connect(function()
	local earned = game_object.Earned
	earned_label.Text = 'Bricks: ' .. suffix(earned)
end)

-- Update Lighting
task.spawn(function()
	while true do
		local tween = tween_service:Create(lighting, TweenInfo.new(1, Enum.EasingStyle.Linear), { ClockTime = (lighting.ClockTime + .1) })

		tween:Play()
		tween.Completed:Wait()
	end
end)

-- Play sounds
task.spawn(function()
	sounds:Play()
end)

-- Prepare camera
repeat camera.CameraType = Enum.CameraType.Scriptable task.wait() until camera.CameraType == Enum.CameraType.Scriptable
camera.CFrame = CFrame.new(6, 1.5, 10) * CFrame.fromEulerAnglesXYZ(0, .3, 0)

-- UI Listeners
control.MouseButton1Down:Connect(function()
	if (game_object.State == 'Inactive') then
		game_object:Start()
		control.Text = 'Click to start!'
		control.TextColor3 = Color3.new(0, 1, 0)
	else
		game_object:Play()
	end
end)

epic.MouseButton1Down:Connect(function()
	sounds:Epic()
end)

shop.MouseButton1Down:Connect(function()
	shop_toggled = not shop_toggled

	if (is_tweening) then return end

	local info = TweenInfo.new(.3, Enum.EasingStyle.Linear)

	if (shop_toggled) then
		shop.Text = '<font color="rgb(255, 0, 0)">Close</font> shop!'

		-- Tween ShopFrame
		local tween = tween_service:Create(shop_frame, info, { Size = UDim2.fromScale(.163, .566) })

		tween:Play()
		is_tweening = true
		tween.Completed:Wait()
		is_tweening = false

		-- Toggle ShopFrame
		for _, v in pairs(shop_frame:GetChildren()) do
			if (v:IsA('GuiObject')) then
				v.Visible = true
				task.wait(.1)
			end
		end
	else
		shop.Text = '<font color="rgb(0, 255, 0)">Open</font> shop!'

		local children = shop_frame:GetChildren()

		local tween = tween_service:Create(shop_frame, info, { Size = UDim2.fromScale(0, .566) })

		-- Toggle ShopFrame
		for i = #children, 0, -1 do
			local instance = children[i]

			if (instance and instance:IsA('GuiObject')) then
				instance.Visible = false
				task.wait(.1)
			end
		end

		tween:Play()
		is_tweening = true
		tween.Completed:Wait()
		is_tweening = false
	end
end)

reduce_chance.MouseButton1Down:Connect(function()
	local cost = shop_costs.reduce
	local current = game_object.Reduce
	local earned = game_object.Earned

	-- Make sure the player can purchase the upgrade
	if (earned >= cost) then
		shop_costs.reduce = math.floor((current + cost) * 1.4)
		game_object.Reduce -= math.clamp(math.abs(current / 10), 0, 1)

		game_object.Earned -= cost
		game_object('Earned'):Fire()
		reduce_chance.Text = string.format('Reduce Fall Chance: <font color="rgb(255, 179, 2)">%s</font>', suffix(shop_costs.reduce))
	end
end)

extra_stack_chance.MouseButton1Down:Connect(function()
	local cost = shop_costs.stack
	local current = game_object.Extra
	local earned = game_object.Earned

	-- Make sure the player can purchase the upgrade
	if (earned >= cost) then
		shop_costs.stack = math.floor((current + cost) * 1.8)
		game_object.Extra -= math.clamp(math.abs(current / 10), 0, 1)

		game_object.Earned -= cost
		game_object('Earned'):Fire()

		extra_stack_chance.Text = string.format('Extra Stack Chance: <font color="rgb(255, 179, 2)">%s</font>', suffix(shop_costs.stack))
	end
end)

brick_multiplier.MouseButton1Down:Connect(function()
	local cost = shop_costs.multiplier
	local current = game_object.Multiplier
	local earned = game_object.Earned

	-- Make sure the player can purchase the upgrade
	if (earned >= cost) then
		shop_costs.multiplier = math.floor((current + cost) * 1.2)
		game_object.Multiplier += 5

		game_object.Earned -= cost
		game_object('Earned'):Fire()

		brick_multiplier.Text = string.format('Brick multiplier: <font color="rgb(255, 179, 2)">%s</font>', suffix(shop_costs.multiplier))
	end
end)