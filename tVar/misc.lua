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
	end
	
	if tVar.logInterp then
		logfile = io.open ("tVarLog.log","a+")
		logfile:write(str.."\n")
		logfile:close()
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
	print(str)
	if tVar.logInterp then
		logfile = io.open ("tVarLog.log","a+")
		logfile:write(str.."\n")
		logfile:close()
	end
	assert(loadstring(str))()
end

function tVar.dataTypeFormat(value)
	if type(value) == "string" then
		return "\"" .. value .. "\""
	elseif type(value) == "boolean" then
		return tostring(value)
	elseif type(value) == "table" then
		local genStringTable = "{"
		for r=1,#value do
			genStringTable = genStringTable .. "{"
			for c=1,#value[r] do
				genStringTable = genStringTable .. value[r][c].val .. ","
			end
			genStringTable = string.sub(genStringTable,1,-2)
			genStringTable = genStringTable .. "},"
		end
		genStringTable = string.sub(genStringTable,1,-2) .. "}"
		return genStringTable
	else
		return value
	end
end

function tVar.clearGlobal()
	tVar.globalFile = io.open("tvarglobal.data","w")
	tVar.closeGlobal()
end

function tVar.initGlobal()
	tVar.globalFile = io.open("tvarglobal.data","+a")
end

function tVar.loadGlobal()
	dofile("tvarglobal.data")
end

function tVar.closeGlobal()
	tVar.globalFile:close()
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