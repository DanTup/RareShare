RareShareTests = {}

function RareShareTests:ResetEnvironment()
end

function assert_eq(x, y, m)
	if x == nil and y == nil then return end
	if m == nil then m = "" end
	if x ~= nil and y == nil then
		error("Assert fail: "..x.." ~= nil : "..m)
	end
	if y ~= nil and x == nil then
		error("Assert fail: nil ~= "..y.." : "..m)
	end
	if x ~= y then
		error("Assert fail: "..x.." ~= "..y.." : "..m)
	end
end

function assert_tables_eq(t1, t2)
	for k, v in pairs(t1) do
		assert_eq(t1[k], t2[k], k)
	end
	for k, v in pairs(t2) do
		assert_eq(t1[k], t2[k], k)
	end
end

function clone(orig)
	local copy = {}
	for k, v in pairs(orig) do
		copy[k] = v
	end
	return copy
end