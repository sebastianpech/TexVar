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
  numeration = true
}
--Redefine tex.print function for debugging 
local oldPrint = tex.print
tex.print = function (_string)
	if tVar.debugMode == "on" then
		oldPrint("{\\tiny \\verb|" .. _string .. "|}\\\\")
	else
		oldPrint(_string)
	end
end
--[[
Public Funktion
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

function tVar:setName(_nameTex)
  self.nameTex = _nameTex
  return self
end

function tVar:clean(_nameTex)
  self.nameTex = _nameTex or self.nameTex
  self.eqNum = self:pFormatVal()
  self.eqTex = self.nameTex
  return self
end

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

function tVar:setUnit(_unit)
	self.unit = _unit
	return self
end

function tVar:bracR()

  self.eqTex = self.encapuslate(self.eqTex,"\\left(","\\right)")
  self.eqNum = self.encapuslate(self.eqNum,"\\left(","\\right)")

  -- Latex probleme wenn klammenr ueber mehere Zeilen gehen. Daher wird bei jedem Umbruch eine symbolische klammer zu bzw. klammer auf gesetzt
  self.eqTex = string.gsub(self.eqTex,"[^\\right.]\\nonumber\\\\&[^\\left.]"," \\right.\\nonumber\\\\&\\left. ")
  self.eqNum = string.gsub(self.eqNum,"[^\\right.]\\nonumber\\\\&[^\\left.]"," \\right.\\nonumber\\\\&\\left. ")

  self.nameTex = self.eqTex
  return self
end

function tVar:CRLF(symb)
  symb = symb or ""
  local ret = getmetatable(self):New(self.val,self.nameTex,false)
  ret.eqTex = self.eqTex .. symb .. " \\nonumber\\\\& "
  ret.eqNum = self.eqNum .. symb .. " \\nonumber\\\\& "
  return ret
end

function tVar:CRLFb(symb)
  symb = symb or ""
  local ret = getmetatable(self):New(self.val,self.nameTex,false)
  ret.eqTex = self.eqTex
  ret.eqNum = " \\nonumber\\\\& " .. symb .. self.eqNum
  return ret
end

function tVar.min(...)
	local arg = table.pack(...)
	local ret = arg[1]:copy()
	local reteqTex = "min(" .. arg[1].nameTex  .. ","
	local reteqNum = "min(" .. arg[1]:pFormatVal() .. ","
	for i=2, #arg do
		if ret > arg[i] then ret = arg[i]:copy() end
		if(i<#arg) then
			reteqTex = reteqTex .. arg[i].nameTex .. ","
			reteqNum = reteqNum .. arg[i]:pFormatVal() .. ","
		else
			reteqTex = reteqTex .. arg[i].nameTex .. ")"
			reteqNum = reteqNum .. arg[i]:pFormatVal() .. ")"
		end
    end
	ret.eqTex = reteqTex
	ret.eqNum = reteqNum
	return ret
end

function tVar.max(...)
	local arg = table.pack(...)
	local ret = arg[1]:copy()
	local reteqTex = "max(" .. arg[1].nameTex  .. ","
	local reteqNum = "max(" .. arg[1]:pFormatVal() .. ","
	for i=2, #arg do
		if ret < arg[i] then ret = arg[i]:copy() end
		if(i<#arg) then
			reteqTex = reteqTex .. arg[i].nameTex .. ","
			reteqNum = reteqNum .. arg[i]:pFormatVal() .. ","
		else
			reteqTex = reteqTex .. arg[i].nameTex .. ")"
			reteqNum = reteqNum .. arg[i]:pFormatVal() .. ")"
		end
    end
	ret.eqTex = reteqTex
	ret.eqNum = reteqNum
	return ret
end

function tVar:printFull()
	if self.nameTex == "" then return self.eqTex .. "=" .. self.eqNum .."=" .. self:pFormatVal() .. "~" .. self.unit end
	return self.nameTex .. "=" .. self.eqTex .. "=" .. self.eqNum .."=" .. self:pFormatVal() .. "~" .. self.unit
end
function tVar:printHalf()
	if self.nameTex == "" then return self.eqTex .. "=" .. self:pFormatVal().. "~" .. self.unit end
	return self.nameTex .. "=" .. self.eqTex .. "=" .. self:pFormatVal().. "~" .. self.unit
end
function tVar:printVar()
	if self.nameTex == "" then return self:pFormatVal().. "~" .. self.unit end
	return self.nameTex .. "=" .. self:pFormatVal().. "~" .. self.unit
end
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
function tVar:out()
  tex.print(self:pFormatVal())
return self
end
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
Metatables
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
	return tVar.formatValue(self.numFormat,self.val)
	--return string.format(self.numFormat,self.val)
end

function tVar.formatValue(numFormat,val)
	local simpleFormat = string.format(numFormat,val)
	local simpleFormatNumber = tonumber(simpleFormat)
	-- check for unary int and surround with brackets
	if simpleFormatNumber < 0 then
		simpleFormat = "(" .. simpleFormat .. ")"
	end
	return simpleFormat
end

function tVar.encapuslate(string,_open,_close)
  return _open .. string .. _close
end

function tVar.Check(_a)
  if(getmetatable(_a) == tVar) then return _a end
  ret = tVar:New(_a,string.format(tVar.numFormat,_a))
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
      row[i] = tVar.formatValue(self.val[j][i],self.numFormat)
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
  ret = tVar:New(_a*1,string.format(tVar.numFormat,_a))
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
