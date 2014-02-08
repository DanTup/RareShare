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
	return (s or ""):gsub("<", "&lt;"):gsub(">", "&gt;")
end


allTests = {}
for name, value in pairs(_G) do
	if StringStarts(name, "test_") then
		name = name:sub(6)
		allTests[name] = value
	end
end

local function ExecuteTests()
	if outputXml then print("<Tests>") end
	failcount = 0
	for name, value in pairs(allTests) do
		RareShareTests:ResetEnvironment()

		local printStack = function(err) return { err, debug.traceback(err) } end
		local pass, err = xpcall(value, printStack)

		if outputXml then
			local info = debug.getinfo(value)

			print("	<Test>")
			print("		<Name>"..XmlEncode(name).."</Name>")
			print("		<DisplayName>"..XmlEncode(name:gsub("_", " ")).."</DisplayName>")
			print("		<CodeFilePath>"..info.source.."</CodeFilePath>")
			print("		<LineNumber>"..info.linedefined.."</LineNumber>")
			print("		<Outcome>"..(pass and "Passed" or "Failed").."</Outcome>")
			if not pass then
				print("		<ErrorMessage>"..XmlEncode(err[1]).."</ErrorMessage>")
				print("		<ErrorStackTrace>"..XmlEncode(err[2]).."</ErrorStackTrace>")
			end
			print("	</Test>")
		else
			if pass then
				print("PASS", name:gsub("_", " "))
			else
				print("FAIL", name:gsub("_", " "))
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
			local info = debug.getinfo(value)

			print("	<Test>")
			print("		<Name>"..XmlEncode(name).."</Name>")
			print("		<DisplayName>"..XmlEncode(name:gsub("_", " ")).."</DisplayName>")
			print("		<File>"..info.source.."</File>")
			print("		<Line>"..info.linedefined.."</Line>")
			print("	</Test>")
		else
			print(name:gsub("_", " "))
		end
	end
	if outputXml then print("</Tests>") end
end

if executeTests then
	ExecuteTests()
else
	ListTests()
end
