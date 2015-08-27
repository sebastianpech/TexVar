----------------------------------------------------------------------------
-- calculation script
-- Contains Metatables and Functions for calculation
--
----------------------------------------------------------------------------
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
-- @param ... (tVar,number) values
-- return (tVar) with min Value
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
--- calculates maximum of tVars
-- 
-- @param ... (tVar,number) values
-- return (tVar) with max Value
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
--- Addition
-- Metatable
--
-- @param _a (tVar,number)
-- @param _b (tVar,number)
-- @return (tVar)
function tVar.Add(_a,_b)
  local a,b = tVar.Check(_a),tVar.Check(_b)

  local ans = tVar:New(a.val + b.val,"ANS")
  ans.eqTex = a.nameTex .. "+" .. b.nameTex
  ans.eqNum = a.eqNum .. "+" .. b.eqNum
  ans.nameTex = ans.eqTex
  return ans
end
--- Subtraction
-- Metatable
--
-- @param _a (tVar,number)
-- @param _b (tVar,number)
-- @return (tVar)
function tVar.Sub(_a,_b)
  local a,b = tVar.Check(_a),tVar.Check(_b)
  local ans = tVar:New(a.val - b.val,"ANS")
  ans.eqTex = a.nameTex .. "-" .. b.nameTex
  ans.eqNum = a.eqNum .. "-" .. b.eqNum
  ans.nameTex = ans.eqTex
  return ans
end
--- Multiplikation
-- Metatable
--
-- @param _a (tVar,number)
-- @param _b (tVar,number)
-- @return (tVar)
function tVar.Mul(_a,_b)
  local a,b = tVar.Check(_a),tVar.Check(_b)

  local ans = tVar:New(a.val * b.val,"ANS")
  ans.eqTex = a.nameTex .. " \\cdot " .. b.nameTex
  ans.eqNum = a.eqNum .. " \\cdot " .. b.eqNum
  ans.nameTex = ans.eqTex
  return ans
end
--- Division
-- Metatable
--
-- @param _a (tVar,number)
-- @param _b (tVar,number)
-- @return (tVar)
function tVar.Div(_a,_b)
  local a,b = tVar.Check(_a),tVar.Check(_b)

  local ans = tVar:New(a.val / b.val,"ANS")
  ans.eqTex = "\\dfrac{" .. a.nameTex .. "}{" .. b.nameTex .. "}"
  ans.eqNum = "\\dfrac{" .. a.eqNum .. "}{" .. b.eqNum .. "}"
  ans.nameTex = ans.eqTex
  return ans
end
--- Unary Minus
-- Metatable
--
-- @param _a (tVar,number)
-- @param _b (tVar,number)
-- @return (tVar)
function tVar.Neg(a)
  local ans = tVar:New(-a.val,"ANS")
  ans.eqTex = "({-"..a.nameTex.."})"
  ans.eqNum = "({-"..a.eqNum.."})"
  ans.nameTex = ans.eqTex
  return ans
end
--- Power
-- Metatable
--
-- @param _a (tVar,number)
-- @param _b (tVar,number)
-- @return (tVar)
function tVar.Pow(a,b)
  local ans = tVar:New(a.val^b,"ANS")
  ans.eqTex = a.nameTex.."^{".. b .."}"
  ans.eqNum = a.eqNum.."^{".. b .."}"
  ans.nameTex = ans.eqTex
  return ans
end
--- Compare Equal
-- Metatable
--
-- @param _a (tVar,number)
-- @param _b (tVar,number)
-- @return (tVar)
function tVar.Equal(a,b)
	if a.val == b.val then return true end
	return false
end
--- Compare Lower than
-- Metatable
--
-- @param _a (tVar,number)
-- @param _b (tVar,number)
-- @return (tVar)
function tVar.LowerT(a,b)
	if a.val < b.val then return true end
	return false
end
--- Compare Lower than Equal
-- Metatable
--
-- @param _a (tVar,number)
-- @param _b (tVar,number)
-- @return (tVar)
function tVar.LowerTe(a,b)
	if a.val <= b.val then return true end
	return false
end