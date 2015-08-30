----------------------------------------------------------------------------
-- calculation script
-- Contains Metatables and Functions for calculation
--
----------------------------------------------------------------------------

--- Addition
-- Metatable
--
-- @param _a (tVar,number)
-- @param _b (tVar,number)
-- @return (tVar)
function tVar.Add(_a,_b)
  local a,b = tVar.Check(_a),tVar.Check(_b)
  
  local ans = tVar:New(nil,"ANS")
  
  if a.val ~= nil and b.val ~= nil then 
    ans.val = a.val + b.val
  end
  
  ans.eqTex = a.nameTex .. "+" .. b.nameTex
  ans.eqNum = a.eqNum .. "+" .. b.eqNum
  ans.nameTex = ans.eqTex
  
  -- history
  ans.history_fun = tVar.Add_N
  ans.history_arg = {a,b}
  
  return ans
end
--- Addition nummeric
--
-- @param _a (number)
-- @param _b (number)
-- @return number
function tVar.Add_N(_a,_b)
	return _a.val+_b.val
end
--- Subtraction
-- Metatable
--
-- @param _a (tVar,number)
-- @param _b (tVar,number)
-- @return (tVar)
function tVar.Sub(_a,_b)
  local a,b = tVar.Check(_a),tVar.Check(_b)
  local ans = tVar:New(nil,"ANS")
  
  if a.val ~= nil and b.val ~= nil then 
	ans.val = a.val - b.val
  end
  
  ans.eqTex = a.nameTex .. "-" .. b.nameTex
  ans.eqNum = a.eqNum .. "-" .. b.eqNum
  ans.nameTex = ans.eqTex
  
  -- history
  ans.history_fun = tVar.Sub_N
  ans.history_arg = {a,b}
  
  return ans
end
--- subtraction nummeric
--
-- @param _a (number)
-- @param _b (number)
-- @return number
function tVar.Sub_N(_a,_b)
	return _a.val - _b.val
end
--- Multiplikation
-- Metatable
--
-- @param _a (tVar,number)
-- @param _b (tVar,number)
-- @return (tVar)
function tVar.Mul(_a,_b)
  local a,b = tVar.Check(_a),tVar.Check(_b)

  local ans = tVar:New(nil,"ANS")
  
  if a.val ~= nil and b.val ~= nil then 
	ans.val = a.val*b.val
  end
  
  ans.eqTex = a.nameTex .. " \\cdot " .. b.nameTex
  ans.eqNum = a.eqNum .. " \\cdot " .. b.eqNum
  ans.nameTex = ans.eqTex
  
  -- history
  ans.history_fun = tVar.Mul_N
  ans.history_arg = {a,b}
  
  return ans
end
--- multiplikation nummeric
--
-- @param _a (number)
-- @param _b (number)
-- @return number
function tVar.Mul_N(_a,_b)
	return _a.val*_b.val
end
--- Division
-- Metatable
--
-- @param _a (tVar,number)
-- @param _b (tVar,number)
-- @return (tVar)
function tVar.Div(_a,_b)
  local a,b = tVar.Check(_a),tVar.Check(_b)

  local ans = tVar:New(nil,"ANS")

  if a.val ~= nil and b.val ~= nil then 
	ans.val = a.val/b.val
  end
  
  ans.eqTex = "\\dfrac{" .. a.nameTex .. "}{" .. b.nameTex .. "}"
  ans.eqNum = "\\dfrac{" .. a.eqNum .. "}{" .. b.eqNum .. "}"
  ans.nameTex = ans.eqTex
  
   -- history
  ans.history_fun = tVar.Div_N
  ans.history_arg = {a,b}
  
  
  return ans
end
--- division nummeric
--
-- @param _a (number)
-- @param _b (number)
-- @return number
function tVar.Div_N(_a,_b)
	return _a.val/_b.val
end
--- Unary Minus
-- Metatable
--
-- @param _a (tVar,number)
-- @param _b (tVar,number)
-- @return (tVar)
function tVar.Neg(_a)
  local a = tVar.Check(_a)
  local ans = tVar:New(nil,"ANS")
  
  if a.val ~= nil then 
    ans.val = -a.val
  end
  
  ans.eqTex = "({-"..a.nameTex.."})"
  ans.eqNum = "({-"..a.eqNum.."})"
  ans.nameTex = ans.eqTex
  
  -- history
  ans.history_fun = tVar.Neg_N
  ans.history_arg = {a}
  
  return ans
end
--- unary nummeric
--
-- @param _a (number)
-- @return number
function tVar.Neg_N(_a)
	return -_a.val
end
--- Power
-- Metatable
--
-- @param _a (tVar,number)
-- @param _b (tVar,number)
-- @return (tVar)
function tVar.Pow(_a,_b)
  local a,b = tVar.Check(_a),tVar.Check(_b)
  local ans = tVar:New(nil,"ANS")
  
  if a.val ~= nil and b.val ~= nil then 
    ans.val = a.val^b.val
  end

  ans.eqTex = a.nameTex.."^{".. b.nameTex .."}"
  ans.eqNum = a.eqNum.."^{".. b.eqNum .."}"
  ans.nameTex = ans.eqTex
  
  -- history
  ans.history_fun = tVar.Pow_N
  ans.history_arg = {a,b}
  
  return ans
end
--- unary nummeric
--
-- @param _a (number)
-- @return number
function tVar.Pow_N(_a,_b)
	return _a.val^_b.val
end
--- Compare Equal
-- Metatable
--
-- @param _a (tVar,number)
-- @param _b (tVar,number)
-- @return (tVar)
function tVar.Equal(a,b)
	if tVar.roundValToPrec(a) == tVar.roundValToPrec(b) then return true end
	return false
end
--- Compare Lower than
-- Metatable
--
-- @param _a (tVar,number)
-- @param _b (tVar,number)
-- @return (tVar)
function tVar.LowerT(a,b)
	if tVar.roundValToPrec(a) < tVar.roundValToPrec(b) then return true end
	return false
end
--- Compare Lower than Equal
-- Metatable
--
-- @param _a (tVar,number)
-- @param _b (tVar,number)
-- @return (tVar)
function tVar.LowerTe(a,b)
	if tVar.roundValToPrec(a) <= tVar.roundValToPrec(b) then return true end
	return false
end
--- calculates root of tVar object
--
-- @param a (tVar) calculate root of this object
-- @param n (number,optional) default=2 nth root
-- @return (tVar) self
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
--- calculates mimimum of tVars
-- 
-- @param (tVar,number) values
-- @return (tVar) with min Value
tVar.min = tVar.link(math.min,"min(",")")
--- calculates maximum of tVars
-- 
-- @param (tVar,number) values
-- @return (tVar) with max Value
tVar.max = tVar.link(math.max,"max(",")")
--- calculates absolute val
-- 
-- @param (tVar,number) values
-- @return (tVar) with max Value
tVar.abs = tVar.link(math.abs,"abs(",")")
--- calculates inverse cosine
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.acos = tVar.link(math.acos,"acos(",")")
--- calculates cosine
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.cos = tVar.link(math.cos,"cos(",")")
--- calculates cosine hyperbolicus 
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.cosh = tVar.link(math.cosh,"cosh(",")")
--- calculates inverse sine
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.asin = tVar.link(math.asin,"asin(",")")
--- calculates sine
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.sin = tVar.link(math.sin,"sin(",")")
--- calculates sine hyperbolicus 
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.sinh = tVar.link(math.sinh,"sinh(",")")
--- calculates inverse tangent
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.atan = tVar.link(math.atan,"atan(",")")
--- calculates tangent
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.tan = tVar.link(math.tan,"tan(",")")
--- calculates tangent hyperbolicus 
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.tanh = tVar.link(math.tanh,"tanh(",")")
--- round up 
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.ceil = tVar.link(math.ceil,"ceil(",")")
--- round down
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.floor = tVar.link(math.floor,"floor(",")")
--- euler function
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.exp = tVar.link(math.exp,"e^{","}")
--- log
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.log = tVar.link(math.log,"log(",")")
--- log10
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.log10 = tVar.link(math.log10,"log10(",")")
--- convert to rad
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.rad = tVar.link(math.rad,"rad(",")")
--- convert to deg
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.deg = tVar.link(math.deg,"deg(",")")
--- calculates inverse tangens with with appr. quadrant
-- 
-- @param opposite (tVar,number) values
-- @param adjacent (tVar,number) values
-- @return (tVar) 
tVar.atan2 = tVar.link(math.atan2,"atan2(",")")
