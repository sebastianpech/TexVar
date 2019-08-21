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
		str = str .. line .. "\n"
	end
	
	tVar.intString(str)

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

	if tVar.logInterp then
		logfile = io.open ("tVarLog.log","a+")
		logfile:write(str.."\n")
		logfile:close()
	end

	if tVar.interpretedShowOutput then
		print(str)
	end

	local status, err = pcall(function () assert(load(str))() end )
	
	if not status then
		getErrorReport(err,str)
	end
	
end

--- Print Error report
--
-- @param err (Number) Error Number
-- @param _string (String) String in which the error occoured
function getErrorReport(err,_string)
	local maxPlaces = 70
	tex.print("\\begin{verbatim}")
	tex.print("------------------------")
	tex.print("| ERROR                |")
	tex.print("------------------------")
	if #err > maxPlaces then
		local countBegin = 1
		while countBegin < #err do
			local lenPlaces = maxPlaces
			if countBegin+maxPlaces > #err then lenPlaces = #err-countBegin end
			tex.print(err:sub(countBegin,countBegin+lenPlaces))
			countBegin = countBegin+lenPlaces+1
		end
	else
		tex.print(err)
	end
	tex.print("------------------------")
	tex.print("| IN CODE              |")
	tex.print("------------------------")
	local counter = 1
	for line in string.gmatch(_string, "([^\n]+)") do
		if #line > maxPlaces then
			local countBegin = 1
			while countBegin < #line do
				local lenPlaces = maxPlaces
				if countBegin+maxPlaces > #line then lenPlaces = #line-countBegin end
				if countBegin == 1 then
					tex.print(counter .. ": " .. line:sub(countBegin,countBegin+lenPlaces))
				else
					tex.print(line:sub(countBegin,countBegin+lenPlaces))
				end
				countBegin = countBegin+lenPlaces+1
			end
		else
			tex.print(counter .. ": " .. line)
		end
		counter = counter + 1
	end
	tex.print("\\end{verbatim}")
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