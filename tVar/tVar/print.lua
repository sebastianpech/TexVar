----------------------------------------------------------------------------
-- print script
-- contains function for output and formatting
--
----------------------------------------------------------------------------

--- Call the number format function according to format definitions tVar
--
-- @return (String) formatted number as string
function tVar:pFormatVal()
	if self.val == nil then return self.nameTex end
	return tVar.formatValue(self.numFormat,self.val,self.decimalSeparator)
	--return string.format(self.numFormat,self.val)
end
--- Format a Number according to a number format and a decimal Separator
--
-- @param numFormat (string) containing the numberformat e.g. %.2f
-- @param val (number) number to be formatted
-- @param decimalSeparator (string) "." gets replaced by decimalSeparator
function tVar.formatValue(numFormat,val,decimalSeparator)
	local simpleFormat = ""
	if val == nil then
		--output with value
		if tVar.coloredOuput then
			simpleFormat = "{\\color{red} undef}"
		else
			simpleFormat = "undef"
		end
	else
		simpleFormat = string.format(numFormat,val)
		local simpleFormatNumber = tonumber(simpleFormat)
		-- check for unary int and surround with brackets
		if simpleFormatNumber < 0 then
			simpleFormat = "(" .. simpleFormat .. ")"
		end
	end
	-- decimal seperator
	simpleFormat = string.gsub(simpleFormat,"%.","{"..decimalSeparator.."}")
	return simpleFormat
end
--- Enxapsulate a String with _open and _close used for brackets
--
-- @param string (string) string to be enclosed
-- @param _open (string) is added before string
-- @param _close (string) is added after string
function tVar.encapuslate(string,_open,_close)
	return _open .. string .. _close
end
--- create string with Name, Result, Equation, Numbers and Unit
-- 
-- @return (string) complete formula
function tVar:printFull()
	if self.nameTex == "" then return self.eqTex .. "=" .. self.eqNum .."=" .. self:pFormatVal() .. "~" .. self.unit end
	return self.nameTex .. "=" .. self.eqTex .. "=" .. self.eqNum .."=" .. self:pFormatVal() .. "~" .. self.unit
end
--- create string with Name, Result, Equation and Unit
-- 
-- @return (string) complete formula
function tVar:printHalf()
	if self.nameTex == "" then return self.eqTex .. "=" .. self:pFormatVal().. "~" .. self.unit end
	return self.nameTex .. "=" .. self.eqTex .. "=" .. self:pFormatVal().. "~" .. self.unit
end
--- create string with Name, Result and Unit
-- 
-- @return (string) complete formula
function tVar:printVar()
	if self.nameTex == "" then return self:pFormatVal().. "~" .. self.unit end
	return self.nameTex .. "=" .. self:pFormatVal().. "~" .. self.unit
end
--- use tex.print to print tVar depending on global definitions
--
-- @return (tVar) self for concatination
function tVar:print()
	local env = self.mathEnviroment
	--RES, RES_EQ, RES_EQ_N,
	local outString = ""
	if self.outputMode == "RES" then
		outString = self:printVar()
	elseif self.outputMode == "RES_EQ" then
		outString = self:printHalf() 
	elseif self.outputMode == "RES_EQ_N" then 
		outString = self:printFull()
	else
		return self
	end

	if env == "" then
		tex.print(outString)
	else
		if not self.numeration then env = env .. "*" end
		tex.print("\\begin{"..env.."}&" .. outString .. "\\end{"..env.."}")
	end
	return self
end
--- use tex.print to print tVar with Name, Result, Equation, Numbers and Unit
--
-- @param numbering (boolean, optional) show numbering besides formula
-- @param enviroment (boolean, optional) use math enviroment
-- @return (tVar) self for concatination
function tVar:outRES_EQ_N(numbering,enviroment)
	if numbering == nil then numbering = self.numeration end 
	if enviroment == nil and self.mathEnviroment ~= "" then enviroment = true end 
	local env = self.mathEnviroment
	if not enviroment then
	  tex.print(self:printFull())
	else
	  if not numbering then env = env .. "*" end
	tex.print("\\begin{"..env.."}&" .. self:printFull() .. "\\end{"..env.."}")
	end
	return self
end
--- use tex.print to print tVar with Name, Result, Equation and Unit
--
-- @param numbering (boolean, optional) show numbering besides formula
-- @param enviroment (boolean, optional) use math enviroment
-- @return (tVar) self for concatination
function tVar:outRES_EQ(numbering,enviroment)
	if numbering == nil then numbering = self.numeration end 
	if enviroment == nil and self.mathEnviroment ~= "" then enviroment = true end 
	local env = self.mathEnviroment
	if not enviroment then
	  tex.print(self:printHalf())
	else
	  if not numbering then env = env .. "*" end
	tex.print("\\begin{"..env.."}&" .. self:printHalf() .. "\\end{"..env.."}")
	end
	return self
end
--- use tex.print to print tVar with Name, Result and Unit
--
-- @param numbering (boolean, optional) show numbering besides formula
-- @param enviroment (boolean, optional) use math enviroment
-- @return (tVar) self for concatination
function tVar:outRES(numbering,enviroment)
	if numbering == nil then numbering = self.numeration end 
	if enviroment == nil and self.mathEnviroment ~= "" then enviroment = true end 
	local env = self.mathEnviroment
	if not enviroment then
	  tex.print(self:printVar())
	else
	  if not numbering then env = env .. "*" end
	  tex.print("\\begin{"..env.."}&" .. self:printVar() .. "\\end{"..env.."}")
	end
	return self
end
--- use tex.print to only print the value
--
-- @return (tVar) self for concatination
function tVar:out()
	tex.print(self:pFormatVal())
	return self
end

function tVar.concatnameTex(_a,_b)
	local a,b
	if getmetatable(_a) == tVar or getmetatable(_a) == tMat or getmetatable(_a) == tVec then
		a = "$".._a.nameTex.."$"
	else
		a = _a
	end
	if getmetatable(_b) == tVar or getmetatable(_b) == tMat or getmetatable(_b) == tVec then
		b = "$".._b.nameTex.."$"
	else
		b = _b
	end
	return a..b
end