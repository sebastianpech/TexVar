-- Unit definitions

tUnit = {}

function tUnit.addsub(a,b)
	if not a or not b then
		return nil,1
	end

	local compatible,factor = tVar.LuaUnits.compatible(a,b)
	if compatible then
		return a,1/factor
	else
		return nil,1
	end
end

function tUnit.mul(a,b)
	if not a and not b then return nil,1 end
	if not a then 
		return b,1
	end
	if b == nil then 
		return a,1
	end
	a_neu = a:copy()

	if #a.stack == 0 then
		tVar.LuaUnits.pushOperation(a_neu,"mul",a)
	end
	if #b.stack == 0 then
		tVar.LuaUnits.pushOperation(a_neu,"mul",b)
	end
	for i=1, #b.stack do
		tVar.LuaUnits.pushOperation(a_neu,b.stack[i].operation,b.stack[i].f)
	end

	local a_neu_match,factor = a_neu:findMatchingUnit()
	if a_neu_match ~= nil then
		a_neu = a_neu_match
	else
		factor = 1
		a_neu.description = ""
	end

	return a_neu,1/factor
end

function tUnit.rootpow(a,b)

	local num,denum = tUnit.dec2frac(b)
	
	--local unit,factor_s = a:simplify()
	local unit,factor_s = a:unfold()

	local a_neu = tVar.LuaUnits:New("")

	for i=1,num do
		if #a.stack == 0 then
			tVar.LuaUnits.pushOperation(a_neu,"mul",a)
		end
		for j=1, #a.stack do
			tVar.LuaUnits.pushOperation(a_neu,a.stack[i].operation,a.stack[i].f)
		end
	end

	if denum ~= 1 then
		a_neu = tVar.LuaUnits:New("")
		local eq_stack = {}
		local eq_stack_f = {}
		local eq_stack_dif = {}

		for i=1,#a_neu.stack do
			local desc = a_neu.stack[i].f.description
			if eq_stack[desc] == nil then
				table.insert(eq_stack_dif,desc)
				table.insert(eq_stack_f,a_neu.stack[i].f)
				eq_stack[desc] = 0
			end
			if a_neu.stack[i].operation == "div" then
				eq_stack[desc] = eq_stack[desc] - 1
			else 
				eq_stack[desc] = eq_stack[desc] + 1
			end
		end

		for i,v in ipairs(eq_stack_dif) do
			local divideable = (math.abs(eq_stack[v]) - math.floor(math.abs(eq_stack[v])/denum)*denum)==0
			local operation = "mul"
			if eq_stack[v] < 0 then 
				operation = "div"
			end
			if divideable then
				
				for i=1,math.abs(eq_stack[v]/denum) do
					tVar.LuaUnits.pushOperation(a_neu,operation,eq_stack_f[v])
				end
			else
				tVar.LuaUnits.pushOperation(a_neu,operation,tVar.LuaUnits:New(v.."^{"..eq_stack[v].."}"))
			end
			
		end

	end

	local a_neu_match,factor = a_neu:findMatchingUnit()
	if a_neu_match ~= nil then
		a_neu = a_neu_match
	else
		factor = 1
		a_neu.description = ""
	end

	return a_neu,1/factor
end

function tUnit.div(a,b)
	if not a and not b then return nil,1 end
	if not a then 
		b_neu = tVar.LuaUnits:New("")

		if #b.stack == 0 then
			tVar.LuaUnits.pushOperation(b_neu,"div",b)
		end

		for i=1, #b.stack do
			local operation = "div"
			if b.stack[i].operation == "div" then operation = "mul" end
			tVar.LuaUnits.pushOperation(b_neu,operation,b.stack[i].f)
		end

		local b_neu_match,factor = b_neu:findMatchingUnit()
		if b_neu_match ~= nil then
			b_neu = b_neu_match
		else
			factor = 1
			b_neu.description = ""
		end
		return b_neu,factor
	end

	if b == nil then 
		return a
	end


	a_neu = a:copy()

	if #a.stack == 0 then
		tVar.LuaUnits.pushOperation(a_neu,"mul",a)
	end

	if #b.stack == 0 then
		tVar.LuaUnits.pushOperation(a_neu,"div",b)
	end

	for i=1, #b.stack do
		local operation = "div"
		if b.stack[i].operation == "div" then operation = "mul" end
		tVar.LuaUnits.pushOperation(a_neu,operation,b.stack[i].f)
	end

	local a_neu_match,factor = a_neu:findMatchingUnit()

	if a_neu_match ~= nil then
		a_neu = a_neu_match
	else
		factor = 1
		a_neu.description = ""
	end

	return a_neu,factor
end


-- Algorithm to convert A Decimal to A Fraction
-- Original paper, written by J. Kennedy, available at:
-- https://sites.google.com/site/johnkennedyshome/home/downloadable-papers/dec2frac.pdf

-- Returns the integer part of a given decimal number
local function int(arg) return math.floor(arg) end

-- Returns a fraction that approximates a given decimal
-- decimal : a decimal to be converted to a fraction
-- acc     : approximation accuracy, defaults to 1e-8
-- returns : two integer values, the numerator and the denominator of the fraction
function tUnit.dec2frac (decimal, acc)
  acc = acc or 1E-4
  local sign, num, denum
  local sign = (decimal < 0) and -1 or 1
  decimal = math.abs(decimal)
  
  if decimal == int(decimal) then --Handles integers
    num = decimal * sign
    denum = 1
    return num, denum
  end
  
  if decimal < 1E-19 then
    num = sign
    denum = 9999999999999999999
  elseif decimal > 1E+19 then
    num = 9999999999999999999 * sign
    denum = 1
  end

  local z = decimal
  local predenum = 0
  local sc
  denum = 1

  repeat
    z = 1 / (z - int(z))
    sc = denum
    denum = denum * int(z) + predenum
    predenum = sc
    num = int(decimal * denum)
  until ((math.abs(decimal - (num / denum)) < acc) or (z == int(z)))

  num = sign * num
  return num, denum
end




tUnit.units = {}
-- Distance
tUnit.units.m = tVar.LuaUnits:New("m"):register()
tUnit.units.mm = tVar.LuaUnits:New("mm"):mul(tUnit.units.m):div(1000):register()
tUnit.units.cm = tVar.LuaUnits:New("cm"):mul(tUnit.units.m):div(100):register()
tUnit.units.dm = tVar.LuaUnits:New("dm"):mul(tUnit.units.m):div(10):register()
tUnit.units.km = tVar.LuaUnits:New("km"):mul(tUnit.units.m):mul(1000):register()
-- Area
tUnit.units.m__2 = tVar.LuaUnits:New("m^2"):mul(tUnit.units.m):mul(tUnit.units.m):register()
tUnit.units.mm__2 = tVar.LuaUnits:New("mm^2"):mul(tUnit.units.mm):mul(tUnit.units.mm):register()
tUnit.units.cm__2 = tVar.LuaUnits:New("cm^2"):mul(tUnit.units.cm):mul(tUnit.units.cm):register()
tUnit.units.dm__2 = tVar.LuaUnits:New("dm^2"):mul(tUnit.units.dm):mul(tUnit.units.dm):register()
tUnit.units.km__2 = tVar.LuaUnits:New("km^2"):mul(tUnit.units.km):mul(tUnit.units.km):register()
-- Volume
tUnit.units.m__3 = tVar.LuaUnits:New("m^3"):mul(tUnit.units.m):mul(tUnit.units.m):mul(tUnit.units.m):register()
tUnit.units.mm__3 = tVar.LuaUnits:New("mm^3"):mul(tUnit.units.mm):mul(tUnit.units.mm):mul(tUnit.units.mm):register()
tUnit.units.cm__3 = tVar.LuaUnits:New("cm^3"):mul(tUnit.units.cm):mul(tUnit.units.cm):mul(tUnit.units.cm):register()
tUnit.units.dm__3 = tVar.LuaUnits:New("dm^3"):mul(tUnit.units.dm):mul(tUnit.units.dm):mul(tUnit.units.dm):register()
tUnit.units.km__3 = tVar.LuaUnits:New("km^3"):mul(tUnit.units.km):mul(tUnit.units.km):mul(tUnit.units.km):register()
-- pow4
tUnit.units.m__4 = tVar.LuaUnits:New("m^4"):mul(tUnit.units.m):mul(tUnit.units.m):mul(tUnit.units.m):mul(tUnit.units.m):register()
tUnit.units.mm__4 = tVar.LuaUnits:New("mm^4"):mul(tUnit.units.mm):mul(tUnit.units.mm):mul(tUnit.units.mm):mul(tUnit.units.mm):register()
tUnit.units.cm__4 = tVar.LuaUnits:New("cm^4"):mul(tUnit.units.cm):mul(tUnit.units.cm):mul(tUnit.units.cm):mul(tUnit.units.cm):register()
tUnit.units.dm__4 = tVar.LuaUnits:New("dm^4"):mul(tUnit.units.dm):mul(tUnit.units.dm):mul(tUnit.units.dm):mul(tUnit.units.dm):register()
tUnit.units.km__4 = tVar.LuaUnits:New("km^4"):mul(tUnit.units.km):mul(tUnit.units.km):mul(tUnit.units.km):mul(tUnit.units.km):register()
-- Weight
tUnit.units.kg = tVar.LuaUnits:New("kg"):register()
tUnit.units.gramm = tVar.LuaUnits:New("g"):mul(tUnit.units.kg):div(1000):register()
tUnit.units.t = tVar.LuaUnits:New("t"):mul(tUnit.units.kg):mul(1000):register()
-- Time 
tUnit.units.s = tVar.LuaUnits:New("s"):register()
tUnit.units.ms = tVar.LuaUnits:New("ms"):mul(tUnit.units.s):div(10E6):register()
tUnit.units.min = tVar.LuaUnits:New("min"):mul(tUnit.units.s):mul(60):register()
tUnit.units.hours = tVar.LuaUnits:New("h"):mul(tUnit.units.s):mul(3600):register()
-- Force
tUnit.units.s__2 = tVar.LuaUnits:New("s^2"):register()
tUnit.units.N = tVar.LuaUnits:New("N"):mul(tUnit.units.kg):mul(tUnit.units.m):div(tUnit.units.s__2):register()
tUnit.units.kN = tVar.LuaUnits:New("kN"):mul(tUnit.units.N):mul(1000):register()
tUnit.units.MN = tVar.LuaUnits:New("MN"):mul(tUnit.units.N):mul(1000000):register()
tUnit.units.GN = tVar.LuaUnits:New("GN"):mul(tUnit.units.N):mul(1000000000):register()
-- Preassure
tUnit.units.Pa = tVar.LuaUnits:New("Pa"):mul(tUnit.units.N):div(tUnit.units.m__2):register()
-- angles
tUnit.units.rad = tVar.LuaUnits:New("rad"):register()
tUnit.units.deg = tVar.LuaUnits:New("°"):mul(tUnit.units.rad):div(180):mul(3.14159265358979323846264338327950):register()

-- temperatur
tUnit.units.kelvin = tVar.LuaUnits:New("K"):register()

-- Watt
tUnit.units.watt =  tVar.LuaUnits:New("W"):mul(tUnit.units.kg):mul(tUnit.units.m__2):div(tUnit.units.s):div(tUnit.units.s):div(tUnit.units.s):register()
-- register all units in tUnit.units

