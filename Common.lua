RareShare = RareShare or {}

function RareShare:StringStarts(s, start)
	return s:sub(1, start:len()) == start
end

function RareShare:StringSplit(s, pattern)
	pattern = pattern or "[^%s]+"
	if pattern:len() == 0 then pattern = "[^%s]+" end
	local parts = {__index = table.insert}
	setmetatable(parts, parts)
	s:gsub(pattern, parts)
	setmetatable(parts, nil)
	parts.__index = nil
	return parts
end

function RareShare:ToInt(x)
	if x == nil then return nil end
	return math.floor(tonumber(x) + .5)
end

function RareShare:UnitID(unit)
	return RareShare:UnitIDFromGuid(UnitGUID(unit))
end

function RareShare:UnitIDFromGuid(unitGuid)
	return tonumber((unitGuid):sub(6, 10), 16)
end

-- HACK!!!! Our terrible string.split doesn't handle empty strings, so this is a big hack to get stuff working
function RareShare:NilToWordNil(x)
	if x == nil then return "nil" end
	return x
end

function RareShare:WordNilToNil(x)
	if x == "nil" then return nil end
	return x
end

function RareShare:Clone(orig)
	local copy = {}
	for k, v in pairs(orig) do
		copy[k] = v
	end
	return copy
end
