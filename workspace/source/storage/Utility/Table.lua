local manager_math = require(script.Parent.Math)
local manager_table = {}

function manager_table.Length(input: table)
	local elements = 0

	for _, _ in next, input do
		elements += 1
	end

	return elements
end

function manager_table.ForEvery(iterator: number, table_to_search: table)
	local reconstructed = {}
	local remainder = {}
	local value = {}

	if (iterator > #table_to_search) then
		remainder = table_to_search
	else
		for i = 1, #table_to_search do
			table.insert(value, table_to_search[i])

			if (manager_math.isInt(i, iterator)) then
				table.insert(reconstructed, table.concat(value))
				value = {}
			end
		end
	end

	return reconstructed, #remainder > 0 and remainder or nil
end

function manager_table.ShallowCopy(table_to_copy: table)
	local copy = {}

	for k, v in pairs(table_to_copy) do
		copy[k] = v
	end

	return copy
end

function manager_table.DeepCopy(table_to_copy: table)
	local copy = {}

	for k, v in pairs(table_to_copy) do
		if (typeof(v) == 'table') then
			copy[k] = manager_table.DeepCopy(v)
		else
			copy[k] = v
		end
	end

	return copy
end

function manager_table.CopyWithBlacklist(table_to_copy: table, blacklist: table)
	local copy = {}

	for k, v in pairs(table_to_copy) do
		if (not table.find(blacklist, k:lower())) then
			if (typeof(v) == 'table') then
				copy[k] = manager_table.DeepCopy(v)
			else
				copy[k] = v
			end
		end
	end

	return copy
end

function manager_table.CopyWithWhitelist(table_to_copy: table, blacklist: table)
	local copy = {}

	for k, v in pairs(table_to_copy) do
		if (table.find(blacklist, k:lower())) then
			if (typeof(v) == 'table') then
				copy[k] = manager_table.DeepCopy(v)
			else
				copy[k] = v
			end
		end
	end

	return copy
end

return manager_table