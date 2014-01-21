function string:starts(start)
	return self:sub(1, start:len()) == start
end