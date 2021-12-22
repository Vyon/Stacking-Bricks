local manager = _G.Manager

-- Services
local players = game:GetService('Players')

-- Modules
local profile_service = manager('ProfileService')
local data_settings = manager('Settings').Datastore
local cache = manager('Cache'):Create('Data')

-- ProfileStore
local profile_store = profile_service.GetProfileStore(data_settings.name, data_settings.template)

-- Main Module
local datastore = {}

-- Public Functions
function datastore.Load(player: Instance)
	local puid = player.UserId
	local key = tostring(puid)
	local profile = profile_store:LoadProfileAsync(key, 'ForceLoad')

	if (profile) then
        profile:Reconcile() --> Save profile data

		-- Profile is no longer in use do this
        profile:ListenToRelease(function()
            player:Kick('\nFailed to load saved data.\n' .. os.date('Time: %I:%M %p\nDate: %x'))
        end)

		-- Is the player still in the game??
        if (player:IsDescendantOf(players)) then
            cache:Add(puid, profile) --> Add player to the data cache

            return profile.Data
        else
            profile:Release()
        end
    else
        player:Kick('\nFailed to create player data.\nPlease submit a bug report in #bugs!')
    end
end

function datastore.Fetch(puid: number)
	local tries = 0

	while not cache:IsEntry(puid) do
		tries += 1

		if (tries > 5) then
			return 'Failed to collect player data.'
		end

		task.wait(1)
	end

	return cache(puid)
end

function datastore.Filter(puid: number)
	local tries = 0

	while not cache:IsEntry(puid) do
		tries += 1

		if (tries > 5) then
			return 'Player\'s data has not loaded.'
		end

		task.wait(1)
	end

	local profile_data = cache(puid).Data

	local reconstructed_data = {}

	for k, v in pairs(profile_data) do
		if (not table.find(data_settings.blacklist, k:lower())) then
			reconstructed_data[k] = v
		end
	end

	return reconstructed_data
end

return datastore