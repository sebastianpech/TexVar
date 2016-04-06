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
		
		a.unit = a.unit or (b.unit and b.unit:copy())
		a.prefUnit = a.prefUnit or (b.prefUnit and b.prefUnit:copy())
		b.unit = b.unit or (a.unit and a.unit:copy())
		b.prefUnit = b.prefUnit or (a.prefUnit and a.prefUnit:copy())
		
    local factor = 1
    if a.unit and not a.unit:compatible(b.unit) then
      error("Cant add two not compatible units")
    elseif b.unit and not b.unit:compatible(a.unit) then
      error("Cant add two not compatible units")
    end

		if a.unit then
			ans.unit = a.unit:copy()
			ans.prefUnit = a.prefUnit:copy()
    elseif b.unit then
      ans.unit = b.unit:copy()
      ans.prefUnit = b.prefUnit:copy()
		end

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

    local factor = 1
		
		a.unit = a.unit or (b.unit and b.unit:copy())
		a.prefUnit = a.prefUnit or (b.prefUnit and b.prefUnit:copy())
		b.unit = b.unit or (a.unit and a.unit:copy())
		b.prefUnit = b.prefUnit or (a.prefUnit and a.prefUnit:copy())
		
    if a.unit and not a.unit:compatible(b.unit) then
      error("Cant sub two not compatible units")
    elseif b.unit and not b.unit:compatible(a.unit) then
      error("Cant sub two not compatible units")
    end
		
		if a.unit then
			ans.unit = a.unit:copy()
			ans.prefUnit = a.prefUnit:copy()
    elseif b.unit then
      ans.unit = b.unit:copy()
      ans.prefUnit = b.prefUnit:copy()
		end

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
  if getmetatable(_b) == tVec or getmetatable(_b) == tMat then return getmetatable(_b).mMul(_a,_b) end

  local a,b = tVar.Check(_a),tVar.Check(_b)
  local ans = tVar:New(nil,"ANS")
  
  if a.val ~= nil and b.val ~= nil then 
		if not a.unit and not b.unit then
			ans.unit = nil
		elseif not b.unit then
			ans.unit = a.unit:copy()
			ans.prefUnit = a.prefUnit:copy()
		elseif not a.unit then
			ans.unit = b.unit:copy()
			ans.prefUnit = b.prefUnit:copy()
		else
			ans.unit = a.unit:mul(1,b.unit)
			ans.prefUnit = a.prefUnit:mul(1,b.unit)
    end
		ans.prefUnit = ans.unit

    ans.val = (a.val * b.val)
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
  if getmetatable(_b) == tVec or getmetatable(_b) == tMat then return getmetatable(_b).mDiv(_a,_b) end
  local a,b = tVar.Check(_a),tVar.Check(_b)

  local ans = tVar:New(nil,"ANS")

  if a.val ~= nil and b.val ~= nil then 
		if not a.unit and not b.unit then
			ans.unit = nil
		elseif not b.unit then
			ans.unit = a.unit:copy()
		elseif not a.unit then
			ans.unit = tVar.units():div(1,b.unit)
		else
			ans.unit = a.unit:div(1,b.unit)
    end
		ans.prefUnit = ans.unit

    ans.val = (a.val/ b.val)
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
-- @return (tVar)
function tVar.Neg(_a)
  local a = tVar.Check(_a)
  local ans = tVar:New(nil,"ANS")
  
  if a.val ~= nil then 
    ans.val = -a.val
		ans.unit = a.unit
		ans.prefUnit = a.prefUnit
  end
  
  ans.eqTex = "\\left({-"..a.nameTex.."}\\right)"
  ans.eqNum = "\\left({-"..a.eqNum.."}\\right)"
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
    
    local factor = 1
    ans.unit = tUnit.rootpow(a.unit,b.val)
		ans.prefUnit = ans.unit
    ans.val = (a.val^b.val)
  end

  ans.eqTex = "{"..a.nameTex.."}^{".. b.nameTex .."}"
  
	if tVar.N_outputWithUnits then
		if a.unit or a.prefUnit then
			ans.eqNum = "{"..a:bracR_N().eqNum.."}^{".. b.eqNum .."}"
		end
	else
		ans.eqNum = "{"..a.eqNum.."}^{".. b.eqNum .."}"
	end
	
  ans.nameTex = ans.eqTex
  
  -- history
  ans.history_fun = tVar.Pow_N
  ans.history_arg = {a,b}
  
  return ans
end
--- Power nummeric
--
-- @param _a (tVar)
-- @param _b (tVar)
-- @return number
function tVar.Pow_N(_a,_b)
	return _a.val^_b.val
end
--- Compare Equal
-- Metatable
--
-- @param a (tVar,number)
-- @param b (tVar,number)
-- @return (tVar)
function tVar.Equal(a,b)
	if tVar.roundValToPrec(a) == tVar.roundValToPrec(b) then return true end
	return false
end
--- Compare Lower than
-- Metatable
--
-- @param a (tVar,number)
-- @param b (tVar,number)
-- @return (tVar)
function tVar.LowerT(a,b)
	if tVar.roundValToPrec(a) < tVar.roundValToPrec(b) then return true end
	return false
end
--- Compare Lower than Equal
-- Metatable
--
-- @param a (tVar,number)
-- @param b (tVar,number)
-- @return (tVar)
function tVar.LowerTe(a,b)
	if tVar.roundValToPrec(a) <= tVar.roundValToPrec(b) then return true end
	return false
end
--- calculates root of tVar object
--
-- @param _a (tVar) calculate root of this object
-- @param _n (number,optional) default=2 nth root
-- @return (tVar) self
function tVar.sqrt(_a,_n)
	_n = _n or 2
	local a,n = tVar.Check(_a),tVar.Check(_n)
	local ans = tVar:New(nil,"ANS")
  
	if a.val ~= nil and n.val ~= nil then 
    local factor = 1
    ans.unit = tUnit.rootpow(a.unit,1/n.val)
		ans.prefUnit = ans.unit
		ans.val = math.pow(a.val,1/n.val)
	end

	local grad = ""
	if n.val > 2 then grad = "[" .. n:pFormatVal() .. "]" end
	ans.eqTex = "\\sqrt".. grad .. "{" .. a.nameTex .. "}"
	ans.eqNum = "\\sqrt".. grad .. "{" .. a.eqNum .. "}"
	ans.nameTex = ans.eqTex
	return ans
end
--- Sqrt nummeric
--
-- @param _a (tVar)
-- @param _n (tVar)
-- @return number
function tVar.sqrt_N(_a,_n)
	return math.pow(_a.val,1/_n)
end
--- calculates mimimum of tVars
-- 
-- @param (tVar,number) values
-- @return (tVar) with min Value
tVar.min = tVar.link(math.min,"\\text{min}\\left(","\\right)",nil,nil,nil,true)
--- calculates maximum of tVars
-- 
-- @param (tVar,number) values
-- @return (tVar) with max Value
tVar.max = tVar.link(math.max,"\\text{max}\\left(","\\right)",nil,nil,nil,true)
--- calculates absolute val
-- 
-- @param (tVar,number) values
-- @return (tVar) with max Value
tVar.abs = tVar.link(math.abs,"\\left|","\\right|",nil,nil,nil,true)
--- calculates inverse cosine
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.acos = tVar.link(math.acos,"\\text{acos}\\left(","\\right)",nil,nil,tVar.units("rad"))
--- calculates cosine
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.cos = tVar.link(math.cos,"\\text{cos}\\left(","\\right)",nil,tVar.units("rad"),nil)
--- calculates cosine hyperbolicus 
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.cosh = tVar.link(math.cosh,"\\text{cosh}\\left(","\\right)",nil,tVar.units("rad"),nil)
--- calculates inverse sine
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.asin = tVar.link(math.asin,"\\text{asin}\\left(","\\right)",nil,nil,tVar.units("rad"))
--- calculates sine
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.sin = tVar.link(math.sin,"\\text{sin}\\left(","\\right)",nil,tVar.units("rad"),nil)
--- calculates sine hyperbolicus 
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.sinh = tVar.link(math.sinh,"\\text{sinh}\\left(","\\right)",nil,tVar.units("rad"),nil)
--- calculates inverse tangent
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.atan = tVar.link(math.atan,"\\text{atan}\\left(","\\right)",nil,nil,tVar.units("rad"))
--- calculates tangent
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.tan = tVar.link(math.tan,"\\text{tan}\\left(","\\right)",nil,tVar.units("rad"),nil)
--- calculates tangent hyperbolicus 
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.tanh = tVar.link(math.tanh,"\\text{tanh}\\left(","\\right)",nil,tVar.units("rad"),nil)
--- round up 
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.ceil = tVar.link(math.ceil,"\\text{ceil}\\left(","\\right)",nil,nil,nil,true)
--- round down
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.floor = tVar.link(math.floor,"\\text{floor}\\left(","\\right)",nil,nil,nil,true)
--- euler function
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.exp = tVar.link(math.exp,"\\text{e}^{","}",nil,nil,nil,false)
--- ln
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.ln = tVar.link(math.log,"\\text{ln}\\left(","\\right)",nil,nil,nil,false)
--- log10
-- 
-- @param (tVar,number) values
-- @return (tVar) 
tVar.log10 = tVar.link(math.log10,"\\text{log10}\\left(","\\right)",nil,nil,nil,false)
--- convert to rad
-- 
-- @param (tVar,number) values
-- @return (tVar) 
--tVar.rad = tVar.link(math.rad,"\\text{rad}\\left(","\\right)")
--- convert to deg
-- 
-- @param (tVar,number) values
-- @return (tVar) 
--tVar.deg = tVar.link(math.deg,"\\text{deg}\\left(","\\right)")
--- calculates inverse tangens with with appr. quadrant
-- 
-- @param opposite (tVar,number) values
-- @param adjacent (tVar,number) values
-- @return (tVar) 
tVar.atan2 = tVar.link(math.atan2,"\\text{atan2}\\left(","\\right)",nil,tVar.units("m"),tVar.units("rad"),false)
--- calc factorial
-- 
-- @param n (number)
-- @return (number) 
function tVar.calcFactorial(n)
  if n<=1 then return 1 end
  return n*tVar.calcFactorial(n-1)
end

tVar.fact = tVar.link(tVar.calcFactorial,"","!",nil,nil,nil,true)

function tVar:solve()
  
  if self.val ~= nil then return self end
  for i=1,#self.history_arg do
    self.history_arg[i]:solve()
  end
  self.val = self.history_fun(unpack(self.history_arg))
  return self
end
