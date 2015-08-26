	--[[
Latex Var CAS
--]]
--Output modes: RES, RES_EQ, RES_EQ_N,
tVar = {
  val = nil,
  nameTex = "",
  eqTex = "",
  eqNum = "",
  unit = "",
  numFormat = "%.3f",
  mathEnviroment = "align",
  debugMode = "off",
  outputMode = "RES",
  numeration = true,
	decimalSeparator = ".",
}
--[[
- Redefine tex.print command for 
- debug output of LaTex Commands
-
- @_string (string) Text for output
]]--
local oldPrint = tex.print
tex.print = function (_string)
	if tVar.debugMode == "on" then
		oldPrint("{\\tiny \\verb|" .. _string .. "|}\\\\")
	else
		oldPrint(_string)
	end
end
--[[
- create new tVar object. tVar has all properties, functions and
- metatables
- 
- @_val (number) value of LaTeX Variable
- @_nameTex (string) LaTeX representation
- @return (tVar) Number with LaTeX representation
--]]
function tVar:New(_val,_nameTex)
	local ret = {}
	setmetatable(ret,self)
	self.__index = self
	self.__add = self.Add
	self.__sub = self.Sub
	self.__mul = self.Mul
	self.__div = self.Div
	self.__pow = self.Pow
	self.__unm = self.Neg
	self.__tostring = self.print
	self.__eq = self.Equal
	self.__lt = self.LowerT
	self.__le = self.LowerTE
	ret.val = _val
	ret.nameTex = _nameTex
	ret.eqNum = ret:pFormatVal()
	return ret
end
--[[
- sets the name of tVar object
- 
- @_nameTex (string) LaTeX representation
- @return (tVar) self
]]--
function tVar:setName(_nameTex)
	self.nameTex = _nameTex
	return self
end
--[[
- removes all calculation steps from tVar object.align
-
- @_nameTex (string, optional) LaTeX representation
- @return self
]]--
function tVar:clean(_nameTex)
	self.nameTex = _nameTex or self.nameTex
	self.eqNum = self:pFormatVal()
	self.eqTex = self.nameTex
	return self
end
--[[
- sets unit of tVar object
-
- @_unit (string) Unit
- @return self
]]--
function tVar:setUnit(_unit)
	self.unit = _unit
	return self
end
--[[
- copy tVar to get rid of references
-
- @return (tVar) copied
]]--
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
--[[
- calculates root of tVar object
-
- @a (tVar) calculate root of this object
- @n (number,optional) default=2 nth root
- @return (tVar) self
]]--
function tVar.sqrt(a,n)
	n = n or 2
	local ans = tVar:New(math.pow(a.val,1/n),"ANS")
	local grad = ""
	if n > 2 then grad = "[" .. n .. "]" end
	ans.eqTex = "\\sqrt".. grad .. "{" .. a.nameTex .. "}"
	ans.eqNum = "\\sqrt".. grad .. "{" .. a.eqNum .. "}"
	ans.nameTex = ans.eqTex
	return ans
end
--[[
- sourrounds the tVar objects eqTex and eqNum with round brackets
-
- @return (tVar) self
]]--
function tVar:bracR()
	self.eqTex = self.encapuslate(self.eqTex,"\\left(","\\right)")
	self.eqNum = self.encapuslate(self.eqNum,"\\left(","\\right)")

	-- Latex probleme wenn klammenr ueber mehere Zeilen gehen. Daher wird bei jedem Umbruch eine symbolische klammer zu bzw. klammer auf gesetzt
	self.eqTex = string.gsub(self.eqTex,"[^\\right.]\\nonumber\\\\&[^\\left.]"," \\right.\\nonumber\\\\&\\left. ")
	self.eqNum = string.gsub(self.eqNum,"[^\\right.]\\nonumber\\\\&[^\\left.]"," \\right.\\nonumber\\\\&\\left. ")

	self.nameTex = self.eqTex
	return self
end
--[[
- adds linebreak in eqNum after tVar
- 
- @symb (string,optional) Symbol is added before and after linebreak
- return (tVar) with brackets
]]--
function tVar:CRLF(symb)
	symb = symb or ""
	local ret = getmetatable(self):New(self.val,self.nameTex,false)
	--ret.eqTex = self.eqTex .. symb .. " \\nonumber\\\\& "
	ret.eqNum = self.eqNum .. symb .. " \\nonumber\\\\& "
	return ret
end
--[[
- adds linebreak in eqNum before tVar
- 
- @symb (string,optional) Symbol is added before and after linebreak
- return (tVar) with brackets
]]--
function tVar:CRLFb(symb)
  symb = symb or ""
  local ret = getmetatable(self):New(self.val,self.nameTex,false)
  ret.eqTex = self.eqTex
  ret.eqNum = " \\nonumber\\\\& " .. symb .. self.eqNum
  return ret
end
--[[
- calculates mimimum of tVars
- 
- @... (tVar,number) values
- return (tVar) with min Value
]]--
function tVar.min(...)
	local arg = table.pack(...)
	local ret = tVar.Check(arg[1]):copy()
	local reteqTex = "min(" .. tVar.Check(arg[1]).eqTex  .. ";"
	local reteqNum = "min(" .. tVar.Check(arg[1]).eqNum .. ";"
	for i=2, #arg do
		if ret > tVar.Check(arg[i]) then ret = tVar.Check(arg[i]):copy() end
		if(i<#arg) then
			reteqTex = reteqTex .. tVar.Check(arg[i]).eqTex .. ";"
			reteqNum = reteqNum .. tVar.Check(arg[i]).eqNum .. ";"
		else
			reteqTex = reteqTex .. tVar.Check(arg[i]).eqTex .. ")"
			reteqNum = reteqNum .. tVar.Check(arg[i]).eqNum .. ")"
		end
    end
	ret.nameTex = reteqTex
	ret.eqTex = reteqTex
	ret.eqNum = reteqNum
	return ret
end
--[[
- calculates maximum of tVars
- 
- @... (tVar,number) values
- return (tVar) with max Value
]]--
function tVar.max(...)
	local arg = table.pack(...)
	local ret = tVar.Check(arg[1]):copy()
	local reteqTex = "max(" .. tVar.Check(arg[1]).eqTex  .. ";"
	local reteqNum = "max(" .. tVar.Check(arg[1]).eqNum .. ";"
	for i=2, #arg do
		if ret < tVar.Check(arg[i]) then ret = tVar.Check(arg[i]):copy() end
		if(i<#arg) then
			reteqTex = reteqTex .. tVar.Check(arg[i]).eqTex .. ";"
			reteqNum = reteqNum .. tVar.Check(arg[i]).eqNum .. ";"
		else
			reteqTex = reteqTex .. tVar.Check(arg[i]).eqTex .. ")"
			reteqNum = reteqNum .. tVar.Check(arg[i]).eqNum .. ")"
		end
    end
	ret.nameTex = reteqTex
	ret.eqTex = reteqTex
	ret.eqNum = reteqNum
	return ret
end
--[[
- create string with Name, Result, Equation, Numbers and Unit
- 
- return (string) complete formula
]]--
function tVar:printFull()
	if self.nameTex == "" then return self.eqTex .. "=" .. self.eqNum .."=" .. self:pFormatVal() .. "~" .. self.unit end
	return self.nameTex .. "=" .. self.eqTex .. "=" .. self.eqNum .."=" .. self:pFormatVal() .. "~" .. self.unit
end
--[[
- create string with Name, Result, Equation and Unit
- 
- return (string) complete formula
]]--
function tVar:printHalf()
	if self.nameTex == "" then return self.eqTex .. "=" .. self:pFormatVal().. "~" .. self.unit end
	return self.nameTex .. "=" .. self.eqTex .. "=" .. self:pFormatVal().. "~" .. self.unit
end
--[[
- create string with Name, Result and Unit
- 
- return (string) complete formula
]]--
function tVar:printVar()
	if self.nameTex == "" then return self:pFormatVal().. "~" .. self.unit end
	return self.nameTex .. "=" .. self:pFormatVal().. "~" .. self.unit
end
--[[
- use tex.print to print tVar depending on global definitions
-
- @return (tVar) self for concatination
]]--
function tVar:print()
	local env = self.mathEnviroment
	--RES, RES_EQ, RES_EQ_N,
	local outString = ""
	if self.outputMode == "RES" then
		outString = self:printVar()
	elseif self.outputMode == "RES_EQ" then
		outString = self:printHalf() 
	else 
		outString = self:printFull()
	end

	if env == "" then
	  tex.print(outString)
	else
	if not self.numeration then env = env .. "*" end
	tex.print("\\begin{"..env.."}&" .. outString .. "\\end{"..env.."}")
	end
	return self
end
--[[
- use tex.print to print tVar with Name, Result, Equation, Numbers and Unit
-
- @numbering (boolean, optional) show numbering besides formula
- @enviroment (boolean, optional) use math enviroment
- @return (tVar) self for concatination
]]--
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
--[[
- use tex.print to print tVar with Name, Result, Equation and Unit
-
- @numbering (boolean, optional) show numbering besides formula
- @enviroment (boolean, optional) use math enviroment
- @return (tVar) self for concatination
]]--
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
--[[
- use tex.print to print tVar with Name, Result and Unit
-
- @numbering (boolean, optional) show numbering besides formula
- @enviroment (boolean, optional) use math enviroment
- @return (tVar) self for concatination
]]--
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
--[[
- use tex.print to print tVar only number
-
- @return (tVar) self for concatination
]]--
function tVar:out()
	tex.print(self:pFormatVal())
return self
end
--[[
- Metatables
-
- @_a (tVar,number)
- @_b (tVar,number)
- @return (tVar)
--]]
function tVar.Add(_a,_b)
  local a,b = tVar.Check(_a),tVar.Check(_b)

  local ans = tVar:New(a.val + b.val,"ANS")
  ans.eqTex = a.nameTex .. "+" .. b.nameTex
  ans.eqNum = a.eqNum .. "+" .. b.eqNum
  ans.nameTex = ans.eqTex
  return ans
end

function tVar.Sub(_a,_b)
  local a,b = tVar.Check(_a),tVar.Check(_b)
  local ans = tVar:New(a.val - b.val,"ANS")
  ans.eqTex = a.nameTex .. "-" .. b.nameTex
  ans.eqNum = a.eqNum .. "-" .. b.eqNum
  ans.nameTex = ans.eqTex
  return ans
end

function tVar.Mul(_a,_b)
  local a,b = tVar.Check(_a),tVar.Check(_b)

  local ans = tVar:New(a.val * b.val,"ANS")
  ans.eqTex = a.nameTex .. " \\cdot " .. b.nameTex
  ans.eqNum = a.eqNum .. " \\cdot " .. b.eqNum
  ans.nameTex = ans.eqTex
  return ans
end

function tVar.Div(_a,_b)
  local a,b = tVar.Check(_a),tVar.Check(_b)

  local ans = tVar:New(a.val / b.val,"ANS")
  ans.eqTex = "\\dfrac{" .. a.nameTex .. "}{" .. b.nameTex .. "}"
  ans.eqNum = "\\dfrac{" .. a.eqNum .. "}{" .. b.eqNum .. "}"
  ans.nameTex = ans.eqTex
  return ans
end

function tVar.Neg(a)
  local ans = tVar:New(-a.val,"ANS")
  ans.eqTex = "({-"..a.nameTex.."})"
  ans.eqNum = "({-"..a.eqNum.."})"
  ans.nameTex = ans.eqTex
  return ans
end
function tVar.Pow(a,b)
  local ans = tVar:New(a.val^b,"ANS")
  ans.eqTex = a.nameTex.."^{".. b .."}"
  ans.eqNum = a.eqNum.."^{".. b .."}"
  ans.nameTex = ans.eqTex
  return ans
end

--[[
Comparing
--]]
function tVar.Equal(a,b)
	if a.val == b.val then return true end
	return false
end
function tVar.LowerT(a,b)
	if a.val < b.val then return true end
	return false
end
function tVar.LowerTe(a,b)
	if a.val <= b.val then return true end
	return false
end

--[[
Private Functions
--]]
function tVar:pFormatVal()
	return tVar.formatValue(self.numFormat,self.val,self.decimalSeparator)
	--return string.format(self.numFormat,self.val)
end

function tVar.formatValue(numFormat,val,decimalSeparator)
	local simpleFormat = string.format(numFormat,val)
	local simpleFormatNumber = tonumber(simpleFormat)
	-- check for unary int and surround with brackets
	if simpleFormatNumber < 0 then
		simpleFormat = "(" .. simpleFormat .. ")"
	end
	-- decimal seperator
	simpleFormat = string.gsub(simpleFormat,"%.","{"..decimalSeparator.."}")
	return simpleFormat
end

function tVar.encapuslate(string,_open,_close)
  return _open .. string .. _close
end

function tVar.Check(_a)
  if(getmetatable(_a) == tVar) then return _a end
  ret = tVar:New(_a,tVar.formatValue(tVar.numFormat,_a,tVar.decimalSeparator))
  ret.eqTex = tVar.formatValue(tVar.numFormat,_a,tVar.decimalSeparator)
  return ret
end
--[[
Konstanten
--]]
tVar.PI = tVar:New(math.pi,"\\pi")
tVar.PI.eqNum = "\\pi"
--[[
tVar Matix und Vektor Modul
--]]
tMat = tVar:New(0,"")
tMat.texStyle = "mathbf"
function tMat:New(_val,_nameTex,displayasmat)
  local ret = {}

  setmetatable(ret,self)
  self.__index = self
  self.__add = self.mAdd
  self.__sub = self.mSub
  self.__mul = self.mMul
  self.__div = self.mDiv
  self.__unm = self.mNeg
  --self.__tostring = self.Print
  ret.val = _val
  ret.nameTex = _nameTex
  if displayasmat or displayasmat == nil then ret.nameTex = "\\" .. self.texStyle .. "{" .. _nameTex .. "}" end
  ret.eqNum = ret:pFormatVal()
  return ret
end

function tMat:setName(_nameTex)
  self.nameTex = "\\" .. self.texStyle .. "{" .. _nameTex .. "}"
end

function tMat:Copy()
  local ret = tMat:New(self.val,self.nameTex)
  ret.eqNum = self.eqNum
  ret.eqTex = self.eqTex
  return ret
end
function tMat:pFormatVal()
  local ret = {}
  for j=1, self:size(1) do
    local row = {}
    for i=1, self:size(2) do
      row[i] = tVar.formatValue(self.numFormat,self.val[j][i],self.decimalSeparator)
    end
    ret[j] = table.concat(row,"&")
  end
  return "\\begin{pmatrix} ".. table.concat(ret,"\\\\") .. " \\end{pmatrix}"
end

function tMat.mAdd(_a,_b)
  local ans = tMat:New({},"ANS")

  local a, b = tMat.Check(_a),tMat.Check(_b)
  -- ab hier a und b entweder tMat oder tVar

  if ((getmetatable(a) == tMat and getmetatable(b) == tMat) or (getmetatable(a) == tVec and getmetatable(b) == tMat) or (getmetatable(a) == tMat and getmetatable(b) == tVec) or (getmetatable(a) == tVec and getmetatable(b) == tVec)) then
    --falls beide Matrizen
    --kontrolle ob gleiche anzahl zeilen und spalten
    if(a:size(1) ~= b:size(1) or a:size(2) ~= b:size(2)) then error ("Matrix Dimensions do not match") end
    ans.val = matrix.add(a.val,b.val)
  else
    error("Can't perform operation Matrix + Skalar")
  end
  if(getmetatable(ans) == tMat) then
    if(ans:size(2) == 1) then
      local tempVal = ans.val
      ans = tVec:New({},"ANS")
      ans.val = tempVal
    end
  end
  ans.eqTex = a.nameTex .. "+" .. b.nameTex
  ans.eqNum = a.eqNum .. "+" .. b.eqNum
  ans.nameTex = ans.eqTex
  return ans
end

function tMat:size(rc)
  if rc == 1 then return #self.val end
  return assert(#self.val[1],1)
end


function tMat.mSub(_a,_b)
  local ans = tMat:New({},"ANS")

  local a, b = tMat.Check(_a),tMat.Check(_b)
  -- ab hier a und b entweder tMat oder tVar

  if ((getmetatable(a) == tMat and getmetatable(b) == tMat) or (getmetatable(a) == tVec and getmetatable(b) == tMat) or (getmetatable(a) == tMat and getmetatable(b) == tVec) or (getmetatable(a) == tVec and getmetatable(b) == tVec)) then
    --falls beide Matrizen
    --kontrolle ob gleiche anzahl zeilen und spalten
    if(a:size(1) ~= b:size(1) or a:size(2) ~= b:size(2)) then error ("Matrix Dimensions do not match") end
    ans.val = matrix.sub(a.val,b.val)
  else
    error("Can't perform operation Matrix + Skalar")
  end

  if(getmetatable(ans) == tMat) then
    if(ans:size(2) == 1) then
      local tempVal = ans.val
      ans = tVec:New({},"ANS")
      ans.val = tempVal
    end
  end
  ans.eqTex = a.nameTex .. "-" .. b.nameTex
  ans.eqNum = a.eqNum .. "-" .. b.eqNum
  ans.nameTex = ans.eqTex
  return ans
end

function tMat.mMul(_a,_b)
  local ans = tMat:New({},"ANS")
  ans.nameTex = ""
  local a, b = tMat.Check(_a),tMat.Check(_b)
  -- ab hier a und b entweder tMat oder tVar
  if ((getmetatable(a) == tMat and getmetatable(b) == tMat) or (getmetatable(a) == tVec and getmetatable(b) == tMat) or (getmetatable(a) == tMat and getmetatable(b) == tVec) or (getmetatable(a) == tVec and getmetatable(b) == tVec)) then
    --falls beide Matrizen
    --kontrolle ob gleiche anzahl zeilen und spalten
    if(a:size(1) ~= b:size(2) or a:size(2) ~= b:size(1)) then error ("Matrix Dimensions do not match") end
    ans.val = matrix.mul(a.val,b.val)
  else
    local mat = tMat:New({},"")
    local scale = tVar:New(0,"")
    if (getmetatable(a) == tMat) then
      mat = a
      scale = b
    else
      mat = b
      scale = a
    end

    ans.val = matrix.mulnum(mat.val,scale.val)
  end
  if(getmetatable(ans) == tMat) then
    if(ans:size(2) == 1) then
      local tempVal = ans.val
      ans = tVec:New({},"ANS")
      ans.val = tempVal
    end
  end

  ans.eqTex = a.nameTex .. " \\cdot " .. b.nameTex
  ans.eqNum = a.eqNum .. " \\cdot " .. b.eqNum
  ans.nameTex = ans.eqTex
  return ans
end

function tMat.mDiv(_a,_b)
  local ans = tMat:New({},"ANS")

  local a, b = tMat.Check(_a),tMat.Check(_b)
  -- ab hier a und b entweder tMat oder tVar

  if ((getmetatable(a) == tMat and getmetatable(b) == tMat) or (getmetatable(a) == tVec and getmetatable(b) == tMat) or (getmetatable(a) == tMat and getmetatable(b) == tVec) or (getmetatable(a) == tVec and getmetatable(b) == tVec)) then
    error("Can't perform division of two Matrices")
  else
    local mat = tMat:New({},"")
    local scale = tVar:New(0,"")
    if (getmetatable(a) == tMat) then
      mat = a
      scale = b
    else
      mat = b
      scale = a
    end

    ans.val = matrix.divnum(mat.val,scale.val)
  end
  if(getmetatable(ans) == tMat) then
    if(ans:size(2) == 1) then
      local tempVal = ans.val
      ans = tVec:New({},"ANS")
      ans.val = tempVal
    end
  end
  ans.eqTex = "\\dfrac{" .. a.nameTex .. "}{" .. b.nameTex .. "}"
  ans.eqNum = "\\dfrac{" .. a.eqNum .. "}{" .. b.eqNum .. "}"
  ans.nameTex = ans.eqTex

  return ans
end

function tMat:T()
  local ans = self:Copy()
  ans.val = matrix.transpose(self.val)

  ans.eqTex = self.nameTex .. "^\\top"
  ans.eqNum = self.eqNum  .. "^\\top"
  ans.nameTex = ans.eqTex
  return ans
end

function tMat:Det()
  local ans = tVar:New(matrix.det(self.val),"ANS")

  ans.eqTex = "|" .. self.nameTex .. "|"
  ans.eqNum = "\\begin{vmatrix} " .. self.eqNum  .. "\\end{vmatrix} "
  ans.nameTex = ans.eqTex
  return ans
end

function tMat:Inv()
  local ans = self:Copy()
  ans.val = matrix.invert(self.val)

  ans.eqTex = self.nameTex .. "^{-1}"
  ans.eqNum = self.eqNum  .. "^{-1}"
  ans.nameTex = ans.eqTex
  return ans
end

function tMat.mNeg(a)
  local ans = a*(-1)

  ans.eqTex = "-"..a.nameTex
  ans.eqNum = "-"..a.eqNum
  ans.nameTex = ans.eqTex
  return ans
end

function tMat.Check(_a)
  if(getmetatable(_a) == tVar or getmetatable(_a) == tMat or getmetatable(_a) == tVec) then return _a end
  ret = tVar:New(_a*1,tVar.formatValue(tVar.numFormat,_a,tVar.decimalSeparator))
  ret.eqTex = tVar.formatValue(tVar.numFormat,_a,tVar.decimalSeparator)
  return ret
end

tVec = tMat:New({},"")
tVec.texStyle = "vec"
function tVec:New(_val,_nameTex,displayasmat)
  local ret = {}

  setmetatable(ret,self)
  self.__index = self
  self.__add = self.mAdd
  self.__sub = self.mSub
  self.__mul = self.mMul
  self.__div = self.mDiv
  self.__unm = self.mNeg
  --self.__tostring = self.Print
  ret.val = {}
  for i=1,#_val do
    ret.val[i] = {_val[i]}
  end
  ret.nameTex = _nameTex
  if displayasmat or displayasmat == nil then ret.nameTex = "\\" .. self.texStyle .. "{" .. _nameTex .. "}" end
  ret.eqNum = ret:pFormatVal()
  return ret
end

function tVec.mMul(_a,_b)
  local ans = tVec:New({},"ANS")
  ans.nameTex = ""
  local a, b = tVec.Check(_a),tVec.Check(_b)
  -- ab hier a und b entweder tMat oder tVar

  if (getmetatable(a) == tVec and getmetatable(b) == tVec) then
    --falls beide Matrizen
    --kontrolle ob gleiche anzahl zeilen und spalten
    if(a:size(1) ~= b:size(1)) then error ("Vector Dimensions do not match") end
    ans = tVar:New((matrix.mul(matrix.transpose(a.val),b.val))[1][1],"ANS")
  else
    local mat = tVec:New({},"")
    local scale = tVar:New(0,"")
    if (getmetatable(a) == tVec) then
      mat = a
      scale = b
    else
      mat = b
      scale = a
    end

    ans.val = matrix.mulnum(mat.val,scale.val)
  end
  ans.eqTex = a.nameTex .. " \\cdot " .. b.nameTex
  ans.eqNum = a.eqNum .. " \\cdot " .. b.eqNum
  ans.nameTex = ans.eqTex
  return ans
end

function tVec:crossP(_b)
  local ans = tVec:New({},"ANS")
  ans.nameTex = ""
  if(getmetatable(self) == tVec and getmetatable(_b) == tVec) then
    if(self:size(1) ~= _b:size(1)) then error ("Vektor dimensions do not match") end
    ans.val = matrix.cross(self.val,_b.val)
  else
    error("Two Vectors needed")
  end
  ans.eqTex = self.nameTex .. " \\times " .. _b.nameTex
  ans.eqNum = self.eqNum .. " \\times " .. _b.eqNum
  ans.nameTex = ans.eqTex
  return ans
end
