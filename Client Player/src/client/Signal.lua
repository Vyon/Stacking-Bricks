local signal = {}
signal.__index = signal

function signal:Fire(...)
	self.Bindable:Fire(...)
	self.APM += 1

	if (self.APM == 1) then
		-- Resets APM (Actions Per Minute)
		task.spawn(task.delay, 60, function()
			self.APM = 0
		end)
	end
end

function signal:Connect(callback)
	assert(typeof(callback) == 'function')

	table.insert(self.Connections, self.Bindable.Event:Connect(callback))
end

function signal:Destroy()
	setmetatable(self, nil)

	-- Deconstruction
	self.Bindable:Destroy()

	for k, v in next, self.Connections do
		v:Destroy()
		table.remove(self.Connections, k)
	end

	for k, _ in next, self do
		self[k] = nil
	end
end

return {
	New = function()
		local self = {}
		self.Connections = {}
		self.Bindable = Instance.new('BindableEvent')
		self.APM = 0

		return setmetatable(self, signal)
	end
}