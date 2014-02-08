require(arg[1])

local outputXml = false
local executeTests = true
for i = 2, #arg do
	if arg[i] == "xml" then outputXml = true end
	if arg[i] == "list" then executeTests = false end
end

local function StringStarts(s, start)
	return s:sub(1, start:len()) == start
end

local function XmlEncode(s)
	-- TODO: Make this better
	return s:gsub("<", "&lt;"):gsub(">", "&gt;")
end


allTests = {}
for name, value in pairs(_G) do
	if StringStarts(name, "test_") then
		name = name:sub(6)
		name =  name:gsub("_", " ")
		allTests[name] = value
	end
end

local function ExecuteTests()
	if outputXml then print("<Tests>") end
	failcount = 0
	for name, value in pairs(allTests) do
		RareShareTests:ResetEnvironment()

		local printStack = function(err) return debug.traceback(err) end
		local pass, err = xpcall(value, printStack)

		if outputXml then
			print("	<Test>")
			print("		<Name>"..XmlEncode(name).."</Name>")
			print("		<Result>"..(pass and "Pass" or "Fail").."</Result>")
			if not pass then
				print("		<Reason>"..XmlEncode(err).."</Reason>")
			end
			print("	</Test>")
		else
			if pass then
				print("PASS", name)
			else
				print("FAIL", name)
				print(err)
			end
		end
		if not pass then failcount = failcount + 1 end
	end
	if outputXml then print("</Tests>") end

	if failcount > 0 then
		if not outputXml then
			print()
			print(failcount.." tests failed!")
		end
		os.exit(1)
	end
end

local function ListTests()
	if outputXml then print("<Tests>") end
	for name, value in pairs(allTests) do
		if outputXml then
			print("	<Test>")
			print("		<Name>"..XmlEncode(name).."</Name>")
			print("	</Test>")
		else
			print(name)
		end
	end
	if outputXml then print("</Tests>") end
end

if executeTests then
	ExecuteTests()
else
	ListTests()
end
