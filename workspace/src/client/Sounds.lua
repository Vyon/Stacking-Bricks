-- Services
local sound_service = game:GetService('SoundService')

local sounds = (function()
	local self = {}
	self.Playing = false
	self.Last = false
	self.Normal = {}

	for _, v in ipairs(sound_service:GetChildren()) do
		if (v:IsA('Sound') and not v.Name:match('Roux') and not v.Name:match('Build')) then
			table.insert(self.Normal, v.Name)
		end
	end

	return self
end)()

function sounds:Play()
	local sound

	local random = function()
		return math.random(1, #self.Normal)
	end

	repeat sound = self.Normal[random()] task.wait() until sound ~= self.Last

	self.Playing = sound

	local sound_instance = sound_service[sound]
	sound_instance:Play()

	local connection; connection = sound_instance.Ended:Connect(function()
		self.Playing = false
		self.Last = sound

		sounds:Play()

		connection:Disconnect()
	end)
end

function sounds:Epic()
	if (self.Playing and not self.Playing:match('Roux')) then
		sound_service[self.Playing]:Stop()

		self.Last = self.Playing
		self.Playing = 'No Roux'

		local sound_instance = sound_service['No Roux']

		sound_instance:Play()
		local connection; connection = sound_instance.Ended:Connect(function()
			self.Last = 'No Roux'
			self.Playing = false

			self:Play()
			connection:Disconnect()
		end)
	else
		return
	end
end

function sounds.Build()
	local sound = sound_service.Build:Clone()
	sound.Parent = sound_service.ActiveSounds

	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

return sounds