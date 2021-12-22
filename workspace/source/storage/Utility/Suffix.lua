-- Variables
local suffixes = {"k","M","B","T","qd","Qn","sx","Sp","O","N","de","Ud","DD","tdD","qdD","QnD","sxD","SpD","OcD","NvD","Vgn","UVg","DVg","TVg","qtV","QnV","SeV","SPG","OVG","NVG","TGN","UTG","DTG","tsTG","qtTG","QnTG","ssTG","SpTG","OcTG","NoTG","QdDR","uQDR","dQDR","tQDR","qdQDR","QnQDR","sxQDR","SpQDR","OQDDr","NQDDr","qQGNT","uQGNT","dQGNT","tQGNT","qdQGNT","QnQGNT","sxQGNT","SpQGNT", "OQQGNT","NQQGNT","SXGNTL"}

return function(amount: number)
	-- Initial Variables
	local negative = amount < 0

	amount = math.abs(amount) --> If "negative" is true get the absolute / positive version of amount

	local isStringified = false

	-- Get amount suffix
	for i = 1, #suffixes do
		if (not (amount >= 10 ^ (3 * i))) then
			amount /= 10 ^ (3 * (i - 1))

			-- Variables
			local amount_string = tostring(amount)
			local isComplex = amount_string:find('.') and amount_string:sub(4, 4) ~= '.'

			amount = amount_string:sub(1, (isComplex and 4) or 3) .. (suffixes[i-1] or '')
			isStringified = true
			break
		end
	end

	-- If amount < 1000
	if (not isStringified) then
		local Rounded = math.floor(amount)
		amount = tostring(Rounded)
	end

	-- If negative display nicely :)
	if (negative) then
		amount = '-' .. amount
	end

	return amount
end