require "Common"
require "TestFunctions"
require "RareShare"
require "TestRares"
require "Tests"
require "Publisher-RareCoordinator"

allTests = {}
for name, value in pairs(_G) do
	if name:starts("test_") then
		name = name:sub(6)
		name =  name:gsub("_", " ")
		allTests[name] = value
	end
end

failcount = 0
for name, value in pairs(allTests) do
	RareShareTests:ResetEnvironment()

	local printStack = function(err) return debug.traceback(err) end
	local pass, err = xpcall(value, printStack)

	if pass then
		print("PASS", name)
	else
		print("FAIL", name)
		print(err)
		failcount = failcount + 1
	end
end

if failcount > 0 then
	print()
	print(failcount.." tests failed!")
	os.exit(1)
end
