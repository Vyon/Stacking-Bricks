-- Dependencies
local signal = require(script.Parent.Signal)

-- Main Module
local replicator = {}
replicator.__index = replicator

-- Public Functions
function replicator:__call(key)
	return self.Data[key]
end

function replicator:Listen(callback)
	assert(typeof(callback) == 'function')

	self.Signal:Connect(callback)
end

return {
	New = function(Init: RemoteFunction, Persistance: RemoteEvent, ...)
		assert(
			typeof(Init) == 'Instance' and typeof(Persistance) == 'Instance' and
			Init.ClassName == 'RemoteFunction' and Persistance.ClassName == 'RemoteEvent'
		)

		local data = Init:InvokeServer(...)

		if (typeof(data) ~= 'table') then
			print('Failed to setup replicator.')
			return
		end

		local self = {}
		self.Data = Init:InvokeServer(...)
		self.Signal = signal.New()

		setmetatable(self, replicator)

		Persistance.OnClientEvent:Connect(function(payload: table)
			assert(typeof(payload) == 'table')

			for k, v in next, payload do
				if (self.Data[k]) then
					self.Data[k] = v
				end
			end

			self.Signal:Fire(self.Data)
		end)

		return self
	end
}