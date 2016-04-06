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
	if not tVar.disableOutput then 
		if tVar.debugMode == "on" then
			oldPrint("{\\tiny \\verb|" .. _string .. "|}\\\\")
		else
			oldPrint(_string)
		end
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
--- sets the numberformat of tVar object
-- 
-- @param _numformat (string) Lua numberformat
-- @return (tVar) self
function tVar:setFormat(_numformat)
	self.numFormat = _numformat
	-- in case the eqNum is equal to the result reinit eqNum concerning _numformat
	if tonumber(self.eqNum) == tonumber(self.val) then
		self.eqNum = self:pFormatVal()
	end
	return self
end
--- removes all calculation steps from tVar object.align
--
-- @param _nameTex (string, optional) LaTeX representation
-- @return self
function tVar:clean(_nameTex)
	self.nameTex = _nameTex or self.nameTex
	self.eqNum = self:pFormatVal()
	
	if self.N_outputInBaseUnits and self.N_outputWithUnits then
			self.eqNum = self.eqNum .. self:getBaseUnit()
	elseif self.N_outputWithUnits then
			self.eqNum = self.eqNum .. self:getUnit()
	end
	
	if self.eqMat then 	self.eqMat = self:pFormatVal() end

	self.eqTex = self.nameTex
	return self
end
--- sets unit of tVar object
--
-- @param _unit (string) Unit
-- @return self
function tVar:setUnit(_unit)
	if not _unit then
		self.prefUnit = tVar.units()
		self.unit = tVar.units()
	elseif not self.unit then
		local factor = 1
		local new = self.eqNum == self:pFormatVal()

		self.prefUnit = tVar.units.fromString(_unit)
		self.unit,factor = self.prefUnit:simplify()
		
		self.val = self.val*factor

		if new and self.N_outputInBaseUnits then
			self.eqNum = self:pFormatVal()
		end
		
		if new and self.N_outputInBaseUnits and self.N_outputWithUnits then
			self.eqNum = self.eqNum .. self:getBaseUnit()
		elseif new and self.N_outputWithUnits then
			self.eqNum = self.eqNum .. self:getUnit()
		end
	else
		local factor = 1
		self.prefUnit = tVar.units.fromString(_unit)
	end
	return self
end
--- clears all unit information
--
-- @param _unit (String, option) converts the value to this unit and removes it afterwards
-- @return self
function tVar:clearUnit(_unit)
	if _unit and self.unit then
		local ret = self.unit:convert(tVar.units.fromString(_unit))
		if ret.factor then
			self.val = self.val/ret.factor
			self.eqNum = self:pFormatVal()
		end
	end
	self.prefUnit = nil
	self.unit = nil
	return self
end
--- sets text after unti of tVar object
--
-- @param _unit (string) Unit
-- @return self
function tVar:setUText(_text)
	self.utext = _text
	return self
end
--- gets unit of tVar object
--
-- @return string
function tVar:getUnit()
	if self.utext then
		return "\\," .. self.unitCommand .. "{" .. self.utext .. "}"
	elseif not self.unit then
		return ""
	end
	return "\\," .. self.unitCommand .. "{" .. (self.prefUnit or self.unit):toString() .. "}"
end
--- gets baseunit of tVar object
--
-- @return string
function tVar:getBaseUnit()
	if not self.unit then
		return self.utext or ""
	end
	return "\\," .. self.unitCommand .. "{" .. (self.unit):toString() .. "}"
end
--- copy tVar to get rid of references
--
-- @return (tVar) copied
function tVar:copy()
	local orig = self
    local copy = getmetatable(self):New(self.val,self.nameTex,false)

	copy.eqTex = orig.eqTex
	copy.eqNum = orig.eqNum
	if orig.unit then
		copy.unit = orig.unit:copy()
	else
		copy.unit = nil
	end
	if orig.prefUnit then
		copy.prefUnit = orig.prefUnit:copy()
	else
		copy.prefUnit = nil
	end
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
	return self:brac("\\left(","\\right)")
end
--- sourrounds the tVar objects eqTex and eqNum with round brackets
--
-- @return (tVar) self
function tVar:bracB()
	return self:brac("\\left[","\\right]")
end
--- sourrounds the tVar objects eqTex and eqNum with round brackets
--
-- @return (tVar) self
function tVar:bracC()
	return self:brac("\\left\\lbrace","\\right\\rbrace")
end
--- sourrounds the tVar objects eqTex with round brackets
--
-- @return (tVar) self
function tVar:bracR_EQ()
	return self:brac_EQ("\\left(","\\right)")
end
--- sourrounds the tVar objects eqTex with round brackets
--
-- @return (tVar) self
function tVar:bracB_EQ()
	return self:brac_EQ("\\left[","\\right]")
end
--- sourrounds the tVar objects eqTex with round brackets
--
-- @return (tVar) self
function tVar:bracC_EQ()
	return self:brac_EQ("\\left\\lbrace","\\right\\rbrace")
end
--- sourrounds the tVar objects  eqNum with round brackets
--
-- @return (tVar) self
function tVar:bracR_N()
	return self:brac_N("\\left(","\\right)")
end
--- sourrounds the tVar objects eqNum with round brackets
--
-- @return (tVar) self
function tVar:bracB_N()
	return self:brac_N("\\left[","\\right]")
end
--- sourrounds the tVar objects eqNum with round brackets
--
-- @return (tVar) self
function tVar:bracC_N()
	return self:brac_N("\\left\\lbrace","\\right\\rbrace")
end
--- sourrounds the tVar objects eqTex and eqNum with any bracket
--
-- @return (tVar) self
function tVar:brac(left,right)
	self.eqTex = self.encapuslate(self.eqTex,left,right)
	self.eqNum = self.encapuslate(self.eqNum,left,right)

	-- Latex probleme wenn klammenr ueber mehere Zeilen gehen. Daher wird bei jedem Umbruch eine symbolische klammer zu bzw. klammer auf gesetzt
	self.eqTex = string.gsub(self.eqTex,"[^\\right.]\\nonumber\\\\&[^\\left.]"," \\right.\\nonumber\\\\&\\left. ")
	self.eqNum = string.gsub(self.eqNum,"[^\\right.]\\nonumber\\\\&[^\\left.]"," \\right.\\nonumber\\\\&\\left. ")

	self.nameTex = self.eqTex
	return self
end
--- sourrounds the tVar objects eqTex  with any bracket
--
-- @return (tVar) self
function tVar:brac_EQ(left,right)
	self.eqTex = self.encapuslate(self.eqTex,left,right)

	-- Latex probleme wenn klammenr ueber mehere Zeilen gehen. Daher wird bei jedem Umbruch eine symbolische klammer zu bzw. klammer auf gesetzt
	self.eqTex = string.gsub(self.eqTex,"[^\\right.]\\nonumber\\\\&[^\\left.]"," \\right.\\nonumber\\\\&\\left. ")
	self.nameTex = self.eqTex
	return self
end
--- sourrounds the tVar objects eqNum with any bracket
--
-- @return (tVar) self
function tVar:brac_N(left,right)
	self.eqNum = self.encapuslate(self.eqNum,left,right)

	-- Latex probleme wenn klammenr ueber mehere Zeilen gehen. Daher wird bei jedem Umbruch eine symbolische klammer zu bzw. klammer auf gesetzt
	self.eqNum = string.gsub(self.eqNum,"[^\\right.]\\nonumber\\\\&[^\\left.]"," \\right.\\nonumber\\\\&\\left. ")

	return self
end
--- adds linebreak in eqNum after tVar
-- 
-- @param symb (string,optional) Symbol is added before and after linebreak
-- return (tVar) with brackets
function tVar:CRLF(symb)
	symb = symb or ""
	local ret = self:copy()
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
  local ret = self:copy()
  ret.eqTex = self.eqTex
  ret.eqNum = " \\nonumber\\\\& " .. symb .. self.eqNum
  return ret
end
--- adds linebreak in eqTex after tVar
-- 
-- @param symb (string,optional) Symbol is added before and after linebreak
-- return (tVar) with brackets
function tVar:CRLF_EQ(symb)
	symb = symb or ""
	local ret = self:copy()
	ret.eqTex = self.eqTex .. symb .. " \\nonumber\\\\& "
	ret.nameTex = ret.eqTex
	ret.eqNum = self.eqNum
	return ret
end
--- adds linebreak in eqTex before tVar
-- 
-- @param symb (string,optional) Symbol is added before and after linebreak
-- @return (tVar) with brackets
function tVar:CRLFb_EQ(symb)
  symb = symb or ""
  local ret = self:copy()
	ret.eqTex = " \\nonumber\\\\& " .. symb .. self.eqTex
	ret.nameTex = ret.eqTex
  ret.eqNum = self.eqNum
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
function tVar.link(luaFunction,texBefore,texAfter,returntype,inputUnit,outputUnit,pipeUnit)
	pipeUnit = pipeUnit or false
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

		-- check every element in arg table in case one is a number
		local anyvalNil = false
		for i,v in ipairs(arg) do
			arg[i] = returntype.Check(v)
			if (arg[i].val == nil) then anyvalNil = true end
		end 
		local ans = returntype:New(nil,"ANS")
		local val = nil

		if anyvalNil == false then
			-- check if all values have the correct unit and transform in case
			if tVar.useUnits then
			if pipeUnit then
				inputUnit = arg[1].unit
				outputUnit = arg[1].unit
			elseif not inputUnit then
				inputUnit = arg[1].unit
			end
				if inputUnit then
					 
					for i,v in ipairs(arg) do
						
						local isCompatible = inputUnit:compatible(v.unit)
						
						if isCompatible then 
							arg[i].val = arg[i].val 
						else
							error("Units not compatible in link function")
						end
					end
				end
			end

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
		
		if tVar.useUnits then
			ans.unit = outputUnit
		end

		return ans
	end
end
--- rounds result to internal precision
--
-- @return (number) val of tVar roundet to calcPrecision
function tVar:roundValToPrec()
	if getmetatable(self) == tVar then
		return math.floor(self.val * 10^self.calcPrecision + 0.5)/10^self.calcPrecision
	else
		return tVar.roundNumToPrec(self)
	end
end
--- rounds result to internal precision
--
-- @param val (number)
-- @return (number) val of tVar roundet to calcPrecision
function tVar.roundNumToPrec(val)
	return math.floor(val * 10^tVar.calcPrecision + 0.5)/10^tVar.calcPrecision
end

--- formats a value with underscores to a latex subscript
-- first _ ist subscript first __ is exponent rest gets ,
-- @param _string with underscore format
-- @return (string) latex subscript
function tVar.formatVarName(_string)
		local nameTex = "{".. _string .."}"
		nameTex = string.gsub(nameTex,"__","}^{",1)
		nameTex = string.gsub(nameTex,"_",",") 
		nameTex = string.gsub(nameTex,",","}_{",1)

		return nameTex
end