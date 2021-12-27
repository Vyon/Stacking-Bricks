repeat task.wait() until game:IsLoaded()

-- Services
local replicated_storage = game:GetService('ReplicatedStorage')
local tween_service = game:GetService('TweenService')

-- Player
local camera = workspace.CurrentCamera

-- Folders
local remotes = replicated_storage.Remotes
local common = replicated_storage.Common

-- Remotes
local render = remotes.Render
local purchase = remotes.Purchase
local notification = remotes.Notification
local session_event = remotes.SessionEvent

local data = remotes.Data
local data_update = remotes.DataUpdate

local session = remotes.Session
local session_update = remotes.SessionUpdate

-- Modules
local replicator = require(common.Replicator)
local elements = require(script.Elements)
local suffix = require(script.Suffix)

-- Replicators
local data_replicator = replicator.New(data, data_update)
local session_replicator = replicator.New(session, session_update)

-- Locals
local parts = Instance.new('Folder', workspace); parts.Name = 'Parts'

-- Modules
local sounds = require(script.Sounds)

-- Variables
local is_tweening = false
local shop_toggled = false

-- Private Functions
local function CreatePart()
	local total = #parts:GetChildren()

	local part = Instance.new('Part', parts)
	part.Name = 'Brick_' .. total
	part.BrickColor = BrickColor.Random()
	part.Anchored = true
	part.Position = Vector3.new(0, (part.Size.Y * total))
	part.CastShadow = false

	local info = TweenInfo.new(.2, Enum.EasingStyle.Linear)

	local destination = part.CFrame * CFrame.new(6, 1.5, 10) * CFrame.fromEulerAnglesXYZ(0, .3, 0)

	sounds.Build()

	local tween = tween_service:Create(camera, info, { CFrame = destination })
	tween:Play()

	tween.Completed:Wait()

	return part
end

local function UpdateDataElements(payload: table)
	local text = {
		reduce_fall_chance = 'Reduce Fall Chance: <font color="rgb(255, 179, 2)">%s</font>',
		extra_brick_chance = 'Extra Brick Chance: <font color="rgb(255, 179, 2)">%s</font>',
		brick_multiplier = 'Brick Multiplier: <font color="rgb(255, 179, 2)">%s</font>'
	}

	for k, v in pairs(payload.Prices) do
		k = k:lower()

		if (elements[k] and text[k]) then
			local instance = elements[k]

			instance.Text = string.format(text[k], suffix(v))
		end
	end

	elements.bricks.Text = 'Bricks: ' .. suffix(math.floor(payload.Bricks))
	elements.record.Text = 'Highest Stack: ' .. suffix(payload.HighestStack)
end

local function UpdateSessionElements(payload: table)
	elements.status.Text = payload.Status
	elements.chance.Text = string.format('Chance to Fall: %.1f%%', payload.Chance)
	elements.height.Text = string.format('Stack\'s height: %s', suffix(payload.Height))
end

-- On Init
do
	UpdateDataElements(data_replicator.Data)
	UpdateSessionElements(session_replicator.Data)

	task.spawn(function()
		sounds:Play()
	end)

	repeat camera.CameraType = Enum.CameraType.Scriptable task.wait() until camera.CameraType == Enum.CameraType.Scriptable
	camera.CFrame = CFrame.new(6, 1.5, 10) * CFrame.fromEulerAnglesXYZ(0, .3, 0)
end

-- Replicator Listeners
data_replicator:Listen(UpdateDataElements)
session_replicator:Listen(UpdateSessionElements)

-- Remote Listeners
render.OnClientEvent:Connect(function(type)
	if (type == 'Brick') then
		CreatePart()
	else
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
	end
end)

notification.OnClientEvent:Connect(function(message)
	elements.notification.Visible = true
	elements.notification.Text = message

	task.wait(7)

	local tween = tween_service:Create(elements.notification, TweenInfo.new(.2), {
		TextTransparency = 1
	})

	tween:Play()

	tween.Completed:Wait()
	elements.notification.Visible = false
	elements.notification.TextTransparency = 0
end)

-- UI Listeners
elements.control.MouseButton1Down:Connect(function()
	local state = session_replicator('State')

	if (state == 'Inactive') then
		session_event:FireServer('Start')
	elseif (state == 'Playing') then
		session_event:FireServer('Click')
	end
end)

elements.epic_sound.MouseButton1Down:Connect(function()
	sounds:Epic()
end)

local shop = elements.shop
local shop_frame = elements.shop_frame

shop.MouseButton1Down:Connect(function()
	shop_toggled = not shop_toggled

	if (is_tweening) then return end

	local info = TweenInfo.new(.3, Enum.EasingStyle.Linear)

	if (shop_toggled) then
		shop.Text = '<font color="rgb(255, 0, 0)">Close</font> shop!'

		-- Tween ShopFrame
		local tween = tween_service:Create(shop_frame, info, { Size = UDim2.fromScale(.163, .45) })

		tween:Play()
		is_tweening = true
		tween.Completed:Wait()

		-- Toggle ShopFrame
		for _, v in pairs(shop_frame:GetChildren()) do
			if (v:IsA('GuiObject')) then
				v.Visible = true
				task.wait(.1)
			end
		end

		is_tweening = false
	else
		shop.Text = '<font color="rgb(0, 255, 0)">Open</font> shop!'

		local children = shop_frame:GetChildren()

		local tween = tween_service:Create(shop_frame, info, { Size = UDim2.fromScale(0, .45) })

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

elements.reduce_fall_chance.MouseButton1Down:Connect(function()
	purchase:FireServer(1)
end)

elements.extra_brick_chance.MouseButton1Down:Connect(function()
	purchase:FireServer(2)
end)

elements.brick_multiplier.MouseButton1Down:Connect(function()
	purchase:FireServer(3)
end)