﻿function string:starts(start)
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

function toint(x)
	if x == nil then return nil end
	return math.floor(tonumber(x) + .5)
end

function UnitID(unit)
	return UnitIDFromGuid(UnitGUID(unit))
end

function UnitIDFromGuid(unitGuid)
	return tonumber((unitGuid):sub(-12, -9), 16)
end

-- HACK!!!! Our terrible string.split doesn't handle empty strings, so this is a big hack to get stuff working
function nilToWordNil(x)
	if x == nil then return "nil" end
	return x
end

function wordNilToNil(x)
	if x == "nil" then return nil end
	return x
end

function clone(orig)
	local copy = {}
	for k, v in pairs(orig) do
		copy[k] = v
	end
	return copy
end
