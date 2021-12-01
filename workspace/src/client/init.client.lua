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
local status = main.Status.Inner
local height = main.Height.Inner
local chance = main.Chance.Inner
local best = main.Best.Inner
local control = main.Control
local epic = main.Epic

-- Locals
local parts = Instance.new('Folder', workspace); parts.Name = 'Parts'

-- Modules
local signal = require(script.Signal)
local sounds = require(script.Sounds)

-- Variables
local isAlive = true

-- Private Functions
local function CreatePart()
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

		local chance = math.floor(math.random() * 100)
		local chance_2 = math.floor(math.random() * 100)

		CreatePart()
		self.Height += 1

		if (self.Chance > 90 and chance_2 > 80) then
			self.Chance += 5
		elseif (chance > 90 and chance_2 > 65) then
			self.Chance = math.floor(self.Chance * .9)
		elseif (chance >= 67) then
			self.Chance += math.clamp(chance / 55, 0, 100)
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

		local info = TweenInfo.new(.05, Enum.EasingStyle.Linear)

		self.Ending = true

		for i = #parts:GetChildren(), 1, -1 do
			camera.CameraType = Enum.CameraType.Scriptable
			local part = parts:GetChildren()[i]

			local destination = part.CFrame * CFrame.new(6, 1.5, 10) * CFrame.fromEulerAnglesXYZ(0, .3, 0)

			local tween = tween_service:Create(part, info, { Transparency = 1 })
			local tween_2 = tween_service:Create(camera, info, { CFrame = destination })

			part.CanCollide = false

			tween:Play()
			tween_2:Play()

			tween_2.Completed:Wait()
			part:Destroy()

			self.Height -= 1
			self('Height'):Fire()
		end

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
		self.Signals = {}
		self.Ending = false

		-- Setup Signals
		do
			self.Signals['Starting'] = signal.New()
			self.Signals['Ending'] = signal.New()
			self.Signals['Height'] = signal.New()
			self.Signals['Chance'] = signal.New()
		end

		return self
	end

	return setmetatable(Constructor(), private)
end)()

game_object('Starting'):Connect(function()
	status.Text = 'Game in progress'
end)

game_object('Ending'):Connect(function()
	game_object.Ending = false
	control.Text = 'Start!'
	status.Text = 'Click to start!'
end)

game_object('Height'):Connect(function()
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

task.spawn(function()
	while true do
		local tween = tween_service:Create(lighting, TweenInfo.new(1, Enum.EasingStyle.Linear), { ClockTime = (lighting.ClockTime + .1) })

		tween:Play()
		tween.Completed:Wait()
	end
end)

repeat camera.CameraType = Enum.CameraType.Scriptable task.wait() until camera.CameraType == Enum.CameraType.Scriptable
camera.CFrame = CFrame.new(6, 1.5, 10) * CFrame.fromEulerAnglesXYZ(0, .3, 0)

task.spawn(function()
	sounds:Play()
end)

control.MouseButton1Down:Connect(function()
	if (game_object.State == 'Inactive') then
		game_object:Start()
		control.Text = 'Click!'
	else
		game_object:Play()
	end
end)

epic.MouseButton1Down:Connect(function()
	sounds:Epic()
end)