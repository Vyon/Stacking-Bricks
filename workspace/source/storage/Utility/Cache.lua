local cache = {}

-- Public Functions
function cache:Create(name)
	if (not self[name]) then
		local object = {}
		object.__index = object

		do
			function object:__call(key)
				key = tostring(key)
				return self[key]
			end

			function object:Add(puid, data)
				puid = tostring(puid)
				data = data or {}

				if (not self[puid]) then
					self[puid] = data
				end
			end

			function object:IsEntry(puid)
				if (self[tostring(puid)]) then
					return true
				end
			end

			function object:Remove(puid)
				puid = tostring(puid)
				self[puid] = nil
			end
		end

		self[name] = setmetatable({}, object)
		return self[name]
	end
end

function cache:Unload(puid)
	for _, v in pairs(self) do
		if (typeof(v) == 'function') then return end

		task.spawn(v.Remove, v, puid)
	end
end

return cache