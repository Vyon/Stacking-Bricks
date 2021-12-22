local base64 = {}

-- Variables
local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

function base64.Encode(input: string)
	assert(typeof(input) == 'string')

	-- Convert input to binary
	local converted = function(str)
		local v1 = str:gsub(".", function(char)
			local binaryString, charByte = "", char:byte()

			for i = 8, 1, -1 do
				local m1 = charByte % 2 ^ i
				local m2 = charByte % 2 ^ (i - 1)
				local some_math = m1 - m2 > 0 and '1' or '0'

				binaryString ..= some_math
			end

			return binaryString
		end)

		return v1 .. '0000'
	end

	-- Convert binary to base64
	local encoded = converted(input):gsub('%d%d%d?%d?%d?%d?', function(binary)
		-- Binary check
		if (#binary < 6) then
			return ''
		end

		local charI = 0

        for i = 1, 6 do
            charI += binary:sub(i, i) == '1' and 2 ^ (6 - i) or 0
        end

		charI += 1

		return chars:sub(charI, charI)
	end)

	encoded ..= ({'', '==', '='})[#input % 3 + 1]

	return encoded
end

function base64.Decode(input: string)
	assert(typeof(input) == 'string')

	input = input:gsub('[^' .. chars .. '=]', '')

	-- Convert what is presumed to be base64 to the binary
	local converted = function(str)
		local converted = str:gsub('.', function(char)
    	    if (char == '=') then
    	        return ''
    	    end

    	    local new, foundChar = '', chars:find(char) - 1

    	    for i = 6, 1, -1 do
				local m1 = foundChar % 2 ^ i
				local m2 = foundChar % 2 ^ (i - 1)

    	        new ..= (m1 - m2 > 0 and '1' or '0')
    	    end

    	    return new
    	end)

		return converted
	end

	-- Convert base64 binary to characters
	local decoded = converted(input):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(binary)
        if (#binary ~= 8) then
            return ''
        end

        local byte = 0

        for i = 1, 8 do
            byte += binary:sub(i, i) == '1' and 2 ^ (8 - i) or 0
        end

        return string.char(byte)
    end)

	return decoded
end

return base64