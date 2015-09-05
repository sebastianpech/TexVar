----------------------------------------------------------------------------
-- misc script
-- contains function not intend to be used by users
--
----------------------------------------------------------------------------

--- Redefine tex.print command for 
-- debug output of LaTex Commands
--
-- @param _string (string) Text for output
------------------------------------
local oldPrint = tex.print
tex.print = function (_string)
	if tVar.debugMode == "on" then
		oldPrint("{\\tiny \\verb|" .. _string .. "|}\\\\")
	else
		oldPrint(_string)
	end
end
--- sets the name of tVar object
-- 
-- @param _nameTex (string) LaTeX representation
-- @return (tVar) self
function tVar:setName(_nameTex)
	self.nameTex = _nameTex
	return self
end
--- removes all calculation steps from tVar object.align
--
-- @param _nameTex (string, optional) LaTeX representation
-- @return self
function tVar:clean(_nameTex)
	self.nameTex = _nameTex or self.nameTex
	self.eqNum = self:pFormatVal()
	if self.eqMat then 	self.eqMat = self:pFormatVal() end

	self.eqTex = self.nameTex
	return self
end
--- sets unit of tVar object
--
-- @param _unit (string) Unit
-- @return self
function tVar:setUnit(_unit)
	self.unit = _unit
	return self
end
--- copy tVar to get rid of references
--
-- @return (tVar) copied
function tVar:copy()
	local orig = self
    local copy = getmetatable(self):New(self.val,self.nameTex,false)

	copy.eqTex = orig.eqTex
	copy.eqNum = orig.eqNum
	copy.unit = orig.unit
	copy.numFormat = orig.numFormat
	copy.mathEnviroment = orig.mathEnviroment
	copy.debugMode = orig.debugMode
	copy.outputMode = orig.outputMode
	copy.numeration = orig.numeration

	return copy
end
--- sourrounds the tVar objects eqTex and eqNum with round brackets
--
-- @return (tVar) self
function tVar:bracR()
	self.eqTex = self.encapuslate(self.eqTex,"\\left(","\\right)")
	self.eqNum = self.encapuslate(self.eqNum,"\\left(","\\right)")

	-- Latex probleme wenn klammenr ueber mehere Zeilen gehen. Daher wird bei jedem Umbruch eine symbolische klammer zu bzw. klammer auf gesetzt
	self.eqTex = string.gsub(self.eqTex,"[^\\right.]\\nonumber\\\\&[^\\left.]"," \\right.\\nonumber\\\\&\\left. ")
	self.eqNum = string.gsub(self.eqNum,"[^\\right.]\\nonumber\\\\&[^\\left.]"," \\right.\\nonumber\\\\&\\left. ")

	self.nameTex = self.eqTex
	return self
end
--- adds linebreak in eqNum after tVar
-- 
-- @param symb (string,optional) Symbol is added before and after linebreak
-- return (tVar) with brackets
function tVar:CRLF(symb)
	symb = symb or ""
	local ret = getmetatable(self):New(self.val,self.nameTex,false)
	--ret.eqTex = self.eqTex .. symb .. " \\nonumber\\\\& "
	ret.eqNum = self.eqNum .. symb .. " \\nonumber\\\\& "
	return ret
end
--- adds linebreak in eqNum before tVar
-- 
-- @param symb (string,optional) Symbol is added before and after linebreak
-- @return (tVar) with brackets
function tVar:CRLFb(symb)
  symb = symb or ""
  local ret = getmetatable(self):New(self.val,self.nameTex,false)
  ret.eqTex = self.eqTex
  ret.eqNum = " \\nonumber\\\\& " .. symb .. self.eqNum
  return ret
end
--- Checks if overloaded param is tVar or not
-- if not for calculation purposes the overloaded param 
-- is converted to tVar an returned
-- eq number 17 is return as tVar:New(17,"17.0")
--
-- @param _a (tVar,number) param to be cecked
-- @return (tVar) _a as tVar
function tVar.Check(_a)
	if(getmetatable(_a) == tVar) then return _a end
	ret = tVar:New(_a,tVar.formatValue(tVar.numFormat,_a,tVar.decimalSeparator))
	ret.eqTex = tVar.formatValue(tVar.numFormat,_a,tVar.decimalSeparator)
	return ret
end
--- function returns table of vlaues from tVar objects
--
-- @param tVarTable (tVar table)
-- @return table of tVar.val
function tVar.valuesFromtVar(tVarTable)
	local ret = {}
	for i=1, #tVarTable do
		ret[i] = tVarTable[i].val
	end
	return ret
end
--- used for converting lua functions to tVar function with mathematical representation
--
-- @param luaFunction function to be converted to tVar function
-- @param texBefore (string) text is added befor the list of tVar function names
-- @param texAfter (string) same as texBefor but after the list
-- @param returntype (tVar,tMat oder tVec) tVar is default
-- @return (tVar) result of lua function with tVar paramters
function tVar.link(luaFunction,texBefore,texAfter,returntype)
	local returntype = returntype
	if returntype == nil then returntype = tVar end
	local originalFunction = luaFunction
	local _texBefore = texBefore
	local _texAfter = texAfter
	
	local orcalcFunction = function (...)
		local arg = table.pack(...)
		return originalFunction(table.unpack(tVar.valuesFromtVar(arg)))
	end
	
	return function (...)
		local arg = table.pack(...)

		-- cheack every element in arg table in case one is a number
		local anyvalNil = false
		for i,v in ipairs(arg) do
			arg[i] = returntype.Check(v)
			if (arg[i].val == nil) then anyvalNil = true end
		end
		local ans = returntype:New(nil,"ANS")
		local val = nil

		if anyvalNil == false then
			val = originalFunction(table.unpack(returntype.valuesFromtVar(arg)))
			if returntype ~= tVar then
				val = tMat.CheckTable(val)
			end
		end
		
		ans.val = val
		-- concat arg values
		local nameStr = ""
		local numbStr = ""
		for i=1, #arg do
			nameStr = nameStr .. returntype.Check(arg[i]).nameTex
			numbStr = numbStr .. returntype.Check(arg[i]).eqNum
			if i<#arg then
				nameStr = nameStr .. "; "
				numbStr = numbStr .. "; "
			end
		end
		ans.eqTex = _texBefore .. nameStr .. _texAfter
		ans.eqNum = _texBefore .. numbStr .. _texAfter
		ans.nameTex = ans.eqTex
		
		ans.history_fun = orcalcFunction
		ans.history_arg = arg
		
		return ans
	end
end
--- rounds result to internal precision
--
-- @return (number) val of tVar roundet to calcPrecision
function tVar:roundValToPrec()
	return math.floor(self.val * 10^self.calcPrecision + 0.5)/10^self.calcPrecision
end
--- quick input mode converts a string to a variable
-- a_sdf_g_h becomes a_{sdf,g,h}
--
function tVar.q(_)
	if type(_) ~= "table" then
		_={_}
	end
	for i,_string in ipairs(_) do
		local overLoad = string.gmatch(_string,"([^:=]+)")
		local varName = overLoad()
	
		local nameTex = string.gsub(varName,"_",",") -- replace _ with ,
		nameTex = string.gsub(nameTex,",","_{",1) -- replace first , with _{

		local _, count = string.gsub(nameTex, ",", "") -- counter remaining ,
		local _, count2 = string.gsub(nameTex, "{", "") -- counter remaining ,
		if count > 1 then 
			nameTex = string.gsub(nameTex,",","}^") -- replace all , with }^
		else
			if count2 > 0 then
				nameTex = nameTex .. "}"
			end
		end

		nameTex = string.gsub(nameTex,"}^",",",count-1) -- replace remaining }^ except last

		local value = overLoad()
		-- remove special chars from Varname
		varName = string.gsub(varName,"\\","")
		
		-- check if value is number matrix or vector
		if string.sub(value,1,2) == "{{" then --matrix
			
			local value = assert(loadstring("return " .. value))()
			_G[varName]=tMat:New(value,nameTex)
		elseif string.sub(value,1,1) == "{" then -- vector
			local value = assert(loadstring("return " .. value))()
			_G[varName]=tVec:New(value,nameTex)
		else -- number
			_G[varName]=tVar:New(value,nameTex)
		end

		if tVar.qOutput then
			_G[varName]:outRES()
		end
	end
end
