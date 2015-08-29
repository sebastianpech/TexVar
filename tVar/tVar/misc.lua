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
-- @return (tVar) result of lua function with tVar paramters
function tVar.link(luaFunction,texBefore,texAfter)
	local originalFunction = luaFunction
	local _texBefore = texBefore
	local _texAfter = texAfter
	return function (...)
		local arg = table.pack(...)
		local ans = tVar:New(originalFunction(table.unpack(tVar.valuesFromtVar(arg))),"ANS")
		-- concat arg values
		local nameStr = ""
		local numbStr = ""
		for i=1, #arg do
			nameStr = nameStr .. tVar.Check(arg[i]).nameTex
			numbStr = numbStr .. tVar.Check(arg[i]).eqNum
			if i<#arg then
				nameStr = nameStr .. "; "
				numbStr = numbStr .. "; "
			end
		end
		ans.eqTex = _texBefore .. nameStr .. _texAfter
		ans.eqNum = _texBefore .. numbStr .. _texAfter
		ans.nameTex = ans.eqTex
		return ans
	end
end