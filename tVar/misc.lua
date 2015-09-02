----------------------------------------------------------------------------
-- global misc script
-- contains function tend to be useed by every module
--
----------------------------------------------------------------------------

--- Version Control
tVar.getVersion = function()
tex.print("Version: " .. tVar.Version)
end

--- Easy Input loads a script written in easy input format
-- translates it into functions and runs the script
--
-- Easy Input style:
-- #This is a comment --> tex.print("This is a comment")
-- a_1=3 --> a_1=tVar:New(3,"a_{1}")
--
-- @param path path to easy input file
function tVar.interpret(path)
	local file = assert(io.open(path, "r"))
	for line in file:lines() do

		local interpLine = tVar.interpretEasyInputLine(line)
		-- run string command
		assert(loadstring(interpLine))()
	end
end

--- Interpret Easy Input definitions
--
-- @param line easy input formatted line
-- @return translated command
function tVar.interpretEasyInputLine(line)
	if string.sub(line,1,1) == "#" then -- check if line is comment e.g starts with #
		return "tex.print(\"".. string.sub(line,2,-1) .. "\")"
	elseif string.find(line,":=") ~= nil then -- check if it is a quick input command
		return "tVar.q(\"" .. line .. "\")"
	else -- calculation
		return line
	end
end