--[[
Latex Var CAS
--]]
tVar = {
  val = nil,
  nameTex = "",
  eqTex = "",
  eqNum = "",
  numFormat = "%.3f",
}
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
  self.__tostring = self.Print
  ret.val = _val
  ret.nameTex = _nameTex
  ret.eqNum = ret:pFormatVal()
  return ret
end

function tVar:fix(_nameTex)
  self.nameTex = _nameTex or self.nameTex
  self.eqNum = self:pFormatVal()
  self.eqTex = self.nameTex
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

function tVar.ow(a,b)
  n = n or 2
  local ans = tVar:New(a.val^b,"ANS")
  ans.eqTex = a.nameTex .. "^{".. b.."}"
  ans.eqNum =  a.eqNum .. "^{".. b.."}"
  ans.nameTex = ans.eqTex
  return ans
end

function tVar:bracR()
  
  self.eqTex = self.encapuslate(self.eqTex,"\\left(","\\right)")
  self.eqNum = self.encapuslate(self.eqNum,"\\left(","\\right)")
  self.nameTex = self.eqTex
  return self
end

function tVar:printFull()
  return self.nameTex .. "=" .. self.eqTex .. "=" .. self.eqNum .."=" .. self:pFormatVal()
end
function tVar:printHalf()
  return self.nameTex .. "=" .. self.eqTex .. "=" .. self:pFormatVal()
end
function tVar:printVar()
  return self.nameTex .. "=" .. self:pFormatVal()
end
--[[
Metatables
--]]
function tVar.Add(_a,_b)
  a,b = tVar.Check(_a),tVar.Check(_b)
  
  local ans = tVar:New(a.val + b.val,"ANS")
  ans.eqTex = a.nameTex .. "+" .. b.nameTex
  ans.eqNum = a.eqNum .. "+" .. b.eqNum
  ans.nameTex = ans.eqTex
  return ans
end

function tVar.Sub(_a,_b)
  a,b = tVar.Check(_a),tVar.Check(_b)
  
  local ans = tVar:New(a.val - b.val,"ANS")
  ans.eqTex = a.nameTex .. "-" .. b.nameTex
  ans.eqNum = a.eqNum .. "-" .. b.eqNum
  ans.nameTex = ans.eqTex
  return ans
end

function tVar.Mul(_a,_b)
  a,b = tVar.Check(_a),tVar.Check(_b)
  
  local ans = tVar:New(a.val * b.val,"ANS")
  ans.eqTex = a.nameTex .. " \\cdot " .. b.nameTex
  ans.eqNum = a.eqNum .. " \\cdot " .. b.eqNum
  ans.nameTex = ans.eqTex
  return ans
end

function tVar.Div(_a,_b)
  a,b = tVar.Check(_a),tVar.Check(_b)
  
  local ans = tVar:New(a.val / b.val,"ANS")
  ans.eqTex = "\\dfrac{" .. a.nameTex .. "}{" .. b.nameTex .. "}"
  ans.eqNum = "\\dfrac{" .. a.eqNum .. "}{" .. b.eqNum .. "}"
  ans.nameTex = ans.eqTex
  return ans
end

function tVar.Print(_a)
  return _a:pFormatVal()
end
function tVar.Neg(a)
  local ans = tVar:New(-a.val,"ANS")
  ans.eqTex = "-"..a.nameTex
  ans.eqNum = "-"..a.eqNum 
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
Private Functions
--]]
function tVar:pFormatVal()
  return string.format(self.numFormat,self.val)
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

