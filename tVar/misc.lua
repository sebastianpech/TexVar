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
		--try to find variable Names in text sourroundet by %varname%
		line = tVar.formatStringVariables(line)
		line = tVar.formatStringVariablesValue(line)
		return "tex.print(\"".. string.sub(line,2,-1) .. "\")"
	elseif string.find(line,":=") ~= nil then -- check if it is a quick input command
		local overLoad = string.split(line,":=")
		local varName = overLoad[1]

		local valueAndCommands = string.split(overLoad[2],":")

		local value = valueAndCommands[1]
		local value_n = tonumber(value)
		
		local commands = ""
		for i=2, #valueAndCommands do
			commands = commands .. ":" .. valueAndCommands[i]
		end

		local stripValue = string.gsub(string.gsub(value,"(","")," ","")
		local _, count0 = string.gsub(line, ":print()", "")
		local withPrint = count0 > 0

		if value_n or string.sub(stripValue,1,1) == "{" then 
			local newcommand = ""
				-- check if value is number matrix or vector
			if string.sub(stripValue,1,2) == "{{" then --matrix
				newcommand = "tMat"
			elseif string.sub(value,1,1) == "{" then -- vector
				newcommand = "tVec"
			else -- number
				newcommand = "tVar"
			end
			newcommand = newcommand .. ":New("..value..",\""..  tVar.formatVarName(varName) .."\")"
			
			return string.gsub(varName,"\\","").."="..newcommand..commands	
		else
			if withPrint then
				return string.gsub(varName,"\\","").."=("..string.gsub(overLoad[2],":print","):setName(\"" .. tVar.formatVarName(varName) .. "\"):print")
			else
				return string.gsub(varName,"\\","").."=(".. overLoad[2] .. "):setName(\"" .. tVar.formatVarName(varName) .. "\")"
			end

		end
	else -- calculation
		return line
	end
end
--- String Split
--
--@param str string to split
--@param pat pattern
--@return table
function string.split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end
--- String reformat %varname% to "..varname.."
--
--@param line input stirng
--@retrun string 
function tVar.formatStringVariables(line)
	local splitLine = string.split(line,"%%%%")
	if #splitLine < 2 then return line end
	local retString = ""
	for i=1,#splitLine do
		if i%2==0 then
			retString = retString .. splitLine[i] .. "..\"$"
		else
			if i==#splitLine then return retString .. splitLine[i] end
			retString = retString .. splitLine[i] .. "$\".."
		end
	end
	return retString
end
--- String reformat $$varname$$ to $"..varname:pformatVal().."$
--
--@param line input stirng
--@return string 
function tVar.formatStringVariablesValue(line)
	local splitLine = string.split(line,"%$%$")
	if #splitLine < 2 then return line end
	local retString = ""
	for i=1,#splitLine do
		if i%2==0 then
			retString = retString .. splitLine[i] .. ":pFormatVal()..\"$"
		else
			if i==#splitLine then return retString .. splitLine[i] end
			retString = retString .. splitLine[i] .. "$\".."
		end
	end
	return retString
end