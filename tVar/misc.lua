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
function tVar.intFile(path)
	local file = assert(io.open(path, "r"))
	local str = ""
	for line in file:lines() do
		str = str .. "\n" .. tVar.interpretEasyInputLine(line)
		-- run string command
	end
	assert(loadstring(str))()
end
--- Easy Input analyses a string and
-- translates it into functions and runs the script
--
-- Easy Input style:
-- #This is a comment --> tex.print("This is a comment")
-- a_1=3 --> a_1=tVar:New(3,"a_{1}")
--
-- @param _string path to easy input file
function tVar.intString(_string)
	local str = ""
	for line in string.gmatch(_string, "([^\n]+)") do
		str = str .. "\n" .. tVar.interpretEasyInputLine(line)
	end
	assert(loadstring(str))()
end

--- Interpret Easy Input definitions
--
-- @param line easy input formatted line
-- @return translated command
function tVar.interpretEasyInputLine(line)
	--remove leading \t from file
	while string.sub(line,1,1) == "\t" do
		line = string.sub(line,2,-1)
	end
	if string.sub(line,1,1) == "#" then -- check if line is comment e.g starts with #
		return "tex.print(\"".. string.sub(line,2,-1) .. "\")"
	elseif string.find(line,":=") ~= nil then -- check if it is a quick input command
		local overLoad = string.gmatch(line,"([^:=]+)")
		local varName = overLoad()
		local value = overLoad()
		local value_n = tonumber(value)
		
		local commands = ""
		local com = overLoad()
		while com do
			commands = commands .. ":" .. com
			com = overLoad()
		end

		if value_n or string.sub(value,1,1) == "{" then 
			return "tVar.q(\"" .. line .. "\")"
		else
			return string.gsub(varName,"\\","").."=("..value.."):setName(\"" .. tVar.formatVarName(varName) .. "\")" .. commands
		end
	else -- calculation
		return line
	end
end