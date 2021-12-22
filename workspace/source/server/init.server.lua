local manager = require(script.Manager)

-- Manager Modules
local datastore = manager('Datastore')
local session = manager('Session')
local suffix = manager('Suffix')
local cache = manager('Cache')

-- Cache
local sessions = cache.Sessions

-- Services
local players = game:GetService('Players')
local replicated_storage = game:GetService('ReplicatedStorage')

-- Folders
local remotes = replicated_storage.Remotes

-- Remotes
local on_ready = remotes.OnReady
local purchase = remotes.Purchase
local data_remote = remotes.Data
local data_update = remotes.DataUpdate
local session_remote = remotes.Session
local session_event = remotes.SessionEvent
local notification = remotes.Notification

-- Variables
local ready = {}

-- Listeners
players.PlayerAdded:Connect(function(player)
	local data = datastore.Load(player)
	session.New(player)

	repeat task.wait() until table.find(ready, player.UserId)

	if (data.Claimed == 0 or os.time() >= data.Claimed) then
		data.Claimed = os.time() + 86400
		data.Streak += 1

		local total = (
			(data.Bricks > 100 and data.Bricks or 100) *
			(data.Streak / 10))

		local message = ('You received <font color="rgb(255, 179, 2)">%s bricks</font> from your daily reward!'):format(suffix(total))
		data.Bricks += total
		notification:FireClient(player, message)

		data_update:FireClient(player, datastore.Filter(player.UserId))
	end
end)

players.PlayerRemoving:Connect(function(player)
	cache:Unload(player.UserId)
end)

-- Remote Listeners
data_remote.OnServerInvoke = function(player)
	return datastore.Fetch(player.UserId).Data
end

session_remote.OnServerInvoke = function(player)
	if (not sessions:IsEntry(player.UserId)) then
		return { error=true, message='Player data was not loaded.' }
	end

	local entry = sessions(player.UserId)

	entry = manager.Table.CopyWithWhitelist(
		entry,
		{ 'status', 'height', 'chance', 'state' }
	)

	return entry
end

session_event.OnServerEvent:Connect(function(player: Instance, event_type: string)
	if (typeof(event_type) ~= 'string') then return end

	local player_session = sessions(player.UserId)

	if (event_type:lower() == 'start') then
		player_session:Start()
	elseif (event_type:lower() == 'click') then
		player_session:Play()
	end
end)

purchase.OnServerEvent:Connect(function(player: Instance, p1: number)
	local player_session = sessions(player.UserId)
	player_session:Upgrade(p1)
end)

on_ready.OnServerEvent:Connect(function(player)
	if (not table.find(ready, player.UserId)) then
		table.insert(ready, player.UserId)
	end
end)