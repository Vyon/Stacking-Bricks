-- Services
local server_storage = game:GetService('ServerStorage')

-- Locals
local modules = server_storage.Modules

-- Manager Settings
local SETTINGS = {
	isDebug = false
}

-- Private Functions
return (function()
	-- Setup Manager
	local self = {}

	_G.Manager = setmetatable(self, {
		__call = function(manager, key)
			return manager[key]
		end
	})

	local modules_to_load = { 'Utility', 'Internal', 'External' }

	-- Load Utility functions
	for _, x in ipairs(modules_to_load) do
		if (not modules:FindFirstChild(x)) then continue end

		for _, v in ipairs(modules[x]:GetChildren()) do
			if (v:IsA('ModuleScript')) then
				if (SETTINGS.isDebug) then print(string.format('%s: "%s" is being loaded.', x, v.Name)) end
				self[v.Name] = require(v)
			else
				print(string.format('<%s>%s was found in %s', v.ClassName, v.Name, v.Parent.Name))
			end
		end
	end

	if (SETTINGS.isDebug) then
		print('Loaded', self('Table').Length(self), 'modules')
	end

	return self
end)()