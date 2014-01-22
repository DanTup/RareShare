function string:starts(start)
	return self:sub(1, start:len()) == start
end

function string:split(pattern)
	pattern = pattern or "[^%s]+"
	if pattern:len() == 0 then pattern = "[^%s]+" end
	local parts = {__index = table.insert}
	setmetatable(parts, parts)
	self:gsub(pattern, parts)
	setmetatable(parts, nil)
	parts.__index = nil
	return parts
end
