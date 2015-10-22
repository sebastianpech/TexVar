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
	if tVar.log then
		logfile = io.open ("tVarLog.log","a+")
		logfile:write(str.."\n")
		logfile:close()
	end
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
	if tVar.log then
		logfile = io.open ("tVarLog.log","a+")
		logfile:write(str.."\n")
		logfile:close()
	end
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

		local value_n_test = loadstring("return " .. value)

		local value_n = nil

		if value_n_test then
			_,value_n = pcall(function () return tonumber(value_n_test()) end)

			if not _ then value_n = nil end
		end
		
		local commands = ""
		for i=2, #valueAndCommands do
			commands = commands .. ":" .. valueAndCommands[i]
		end

		local stripValue = string.gsub(string.gsub(value,"(","")," ","")
		local _, count0 = string.gsub(line, ":print()", "")
		local withPrint = count0 > 0

		if string.find(varName,"%(.*%)")~=nil then
			local attrib_str = string.sub(varName,string.find(varName,"%(")+1,-2)
			local attrib_str_format = ""
						local attrib_str_format_n = ""
			local attribs = string.split(attrib_str,",")

			-- remove Latex format
			attrib_str = string.gsub(attrib_str,"\\","")

			local funName = string.sub(varName,1,string.find(varName,"%(")-1)

			local functionString = "function " .. string.gsub(funName,"\\","") .. " (".. attrib_str .. ")"

			for i,att in ipairs(attribs) do
				functionString = functionString .. "\n" .. string.gsub(att,"\\","") .. "=tMat.Check(" .. string.gsub(att,"\\","") .. ",\"".. tVar.formatVarName(att) .."\")"
				attrib_str_format_n = attrib_str_format_n .. string.gsub(att,"\\","") .. ":pFormatVal()" .. "..\",\".."
				attrib_str_format = attrib_str_format .. tVar.formatVarName(att) .. ","
			end

			functionString = functionString .. "\n" .. "local ans=" .. string.gsub(overLoad[2],"\\","")
			functionString = functionString .. "\n" .. "ans.nameTex = \"" .. tVar.formatVarName(funName).. " (\"..".. string.sub(attrib_str_format_n,1,-8) .. "..\")\""
			--functionString = functionString .. "\n" .. "ans.eqTex = \"" .. tVar.formatVarName(funName).. " (".. string.sub(attrib_str_format,1,-2) .. ")\""
			--functionString = functionString .. "\n" .. "ans.eqTex = \"" .. tVar.formatVarName(funName).. " (".. string.sub(attrib_str_format,1,-2) .. ")\""
			functionString = functionString .. "\n" .. "return ans \nend"

			print(functionString)

			return functionString
		elseif value_n or string.sub(stripValue,1,1) == "{" or value == "nil" then 
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
				return string.gsub(varName,"\\","").."=("..string.gsub(overLoad[2],":print","):copy():setName(\"" .. tVar.formatVarName(varName) .. "\"):print")
			else
				return string.gsub(varName,"\\","").."=(".. overLoad[2] .. "):copy():setName(\"" .. tVar.formatVarName(varName) .. "\")"
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
--@param line input string
--@return string 
function tVar.formatStringVariables(line)
	local splitLine = string.split(line,"%%%%")
	if #splitLine < 2 then return line end
	local retString = ""
	for i=1,#splitLine do
		if i%2==0 then
			retString = retString .. splitLine[i] .. "..\""
		else
			if i==#splitLine then return retString .. splitLine[i] end
			retString = retString .. splitLine[i] .. "\".."
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