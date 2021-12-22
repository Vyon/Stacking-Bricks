local manager_string = {}

function manager_string.Random(length: number)
	local chars = {
		'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
		'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
		'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
	}

	local str = ''

	for __ = 1, length do
		local char = chars[math.random(1, #chars)]

		if (math.random(0, 100) > 65) then
			char = char:upper()
		end

		str ..= char
	end

	return str
end

return manager_string