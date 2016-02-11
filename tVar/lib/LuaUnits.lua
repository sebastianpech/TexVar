--[[
 LuaUnits - Version 0.0.1

 DESCRIPTION
 	Basis for calulcation with Units

 EXAMPLE
 	local units = {}
	units.m = LuaUnits:New("m")
	units.mm = LuaUnits:New("mm"):mul(units.m):div(1000)
	units.cm = LuaUnits:New("cm"):mul(units.m):div(100)
	units.dm = LuaUnits:New("dm"):mul(units.m):div(10)
	units.km = LuaUnits:New("km"):mul(units.m):mul(1000)

 API
 	LuaUnits:New(description) -- returns self
 	LuaUnits:mul(f) -- returns self
 	LuaUnits:div(f) -- returns self
 	LuaUnits:convert({prefUnits}) -- returns factor
 	LuaUnits.compatible(unit1,unit2)
 	LuaUnits:printStack()

 DEPENDENCIES
 	No dependencies

 DEVELOPER
	Sebastian Pech - sebastian.pech@zt-pech.at

 LICENSE
 	Copyright (c) 2016 Sebastian Pech

 	MIT LICENSE:
	Permission is hereby granted, free of charge, to any person 
	obtaining a copy of this software and associated documentation 
	files (the "Software"), to deal in the Software without restriction, 
	including without limitation the rights to use, copy, modify, merge, 
	publish, distribute, sublicense, and/or sell copies of the Software, 
	and to permit persons to whom the Software is furnished to do so, 
	subject to the following conditions:

	The above copyright notice and this permission notice shall be included 
	in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH 
	THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]--

local LuaUnits = {}

LuaUnits.__index = LuaUnits
LuaUnits.registeredUnits = {}

function LuaUnits:New(description)
	local child = {}            
	setmetatable(child,self) 
	child.description = description  
	child.stack = {}
	return child
end

function LuaUnits:register()
	local unit = LuaUnits.getByDescription(self.description)
	if not unit then
		table.insert(self.registeredUnits,self)
		return self
	end
	return unit
end

function LuaUnits.getByDescription(description)
	for i,v in ipairs(LuaUnits.registeredUnits) do
		if v.description == description then
			return v
		end
	end
	return nil
end

function LuaUnits:mul(f)
	LuaUnits.pushOperation(self,"mul",f)
	return self
end

function LuaUnits:div(f)
	LuaUnits.pushOperation(self,"div",f)
	return self
end

function LuaUnits.pushOperation(self,operation,f)
	if self:isRegistered() then self:unRegister() end
	if getmetatable(f) == LuaUnits or type(f) == "number" then
		table.insert(self.stack,{["operation"]=operation,["f"]=f})
	else
		error("LuaUnits can only handle Numbers or LuaUnit Tables.")
	end
end

function LuaUnits:unfoldComplete(recursive)
	local recursive = recursive or true
	local unfolded = {}

	for i=1,#self.stack do
		if getmetatable(self.stack[i].f) == LuaUnits then
			if #self.stack[i].f.stack > 0 and recursive then
				local unfoldedSub = self.stack[i].f:unfoldComplete(recursive)
				for j=1,#unfoldedSub do
					local operation = unfoldedSub[j].operation
					if self.stack[i].operation == "div" and operation == "div" then 
						operation = "mul" 
					elseif self.stack[i].operation == "div" and operation == "mul" then 
						operation = "div" 
					elseif self.stack[i].operation == "mul" and operation == "div" then 
						operation = "div"
					elseif self.stack[i].operation == "mul" and operation == "mul" then 
						operation = "mul" 
					end
					table.insert(unfolded,{["operation"]=operation,["f"]=unfoldedSub[j].f})
				end
			else
				table.insert(unfolded,{["operation"]=self.stack[i].operation,["f"]=self.stack[i].f})
			end
		else
			table.insert(unfolded,{["operation"]=self.stack[i].operation,["f"]=self.stack[i].f})
		end
	end
	return unfolded
end

function LuaUnits:convertS(...)
	local prefUnits_unit = {}
	local arg = table.pack(...)
	for i,v in ipairs(arg) do
		table.insert(prefUnits_unit,LuaUnits.getByDescription(v))
	end
	return self:convert(prefUnits_unit)
end

function LuaUnits:convert(prefUnits)

	local factor,unfolded = self:unfold()

	if #self.stack == 0 then
		unfolded = {}
		table.insert(unfolded,{["operation"]="mul",["f"]=self})
		factor = 1
	end

	prefUnits = prefUnits or {}
	for i,v in ipairs(prefUnits) do

		--regular
		local factorPref,unfoldedPref = v:unfold()
		if #v.stack == 0 then
			unfoldedPref = {}
			table.insert(unfoldedPref,{["operation"]="mul",["f"]=v})
			factorPref = 1
		end
		while LuaUnits.containsAll(unfolded,unfoldedPref) do
			for j=1, #unfoldedPref do

				local index = LuaUnits.getIndex(unfolded,unfoldedPref[j])
				table.remove(unfolded,index)
			end

			table.insert(unfolded,{["operation"]="mul",["f"]=prefUnits[i]})
			factor = factor/factorPref
		end

		--inverse
		local factorPref,unfoldedPref = v:unfold()
		if #v.stack == 0 then
			unfoldedPref = {}
			table.insert(unfoldedPref,{["operation"]="div",["f"]=v})
			factorPref = 1
		end

		for j=1, #unfoldedPref do
			if unfoldedPref[j].operation == "mul" then
				unfoldedPref[j].operation = "div"
			elseif unfoldedPref[j].operation == "div" then
				unfoldedPref[j].operation = "mul"
			end
		end
		
		while LuaUnits.containsAll(unfolded,unfoldedPref) do
			for j=1, #unfoldedPref do
				local index = LuaUnits.getIndex(unfolded,unfoldedPref[j])
				table.remove(unfolded,index)
			end
			table.insert(unfolded,{["operation"]="div",["f"]=prefUnits[i]})
			factor = factor*factorPref
		end
	end

	-- create New unit from unfolded
	local ret = LuaUnits:New("")
	ret.stack = unfolded
	ret:mul(factor)

	return factor,ret
end

function LuaUnits:copy()
	local newU = LuaUnits:New(self.description)
	for i,v in ipairs(self.stack) do
		LuaUnits.pushOperation(newU,v.operation,v.f)
	end
	return newU
end

function LuaUnits:format(formatString)
	local unit = self:copy()
	local formatUnit = LuaUnits.generateByString(formatString)
	
	--self:printStack()
	local isCompatible,factor = LuaUnits.compatible(unit,formatUnit)

	if isCompatible then
		return LuaUnits.generateByString(formatString),factor
	else
		return self,1
	end
end

function LuaUnits:formatPref(prefUnits)
	local fact,unit = self:convertS(prefUnits)

	return unit,fact
end

function LuaUnits:simplify(prefUnits)

	if self:isRegistered() then return self,1 end

	local factor,unit = self:convert(prefUnits)
	
	local i,j = unit:findCounterpart()
	while i do
		table.remove(unit.stack,j)
		table.remove(unit.stack,i)
		
		i,j = unit:findCounterpart()
	end

	local removeIndiz = {}
	
	for i,v in ipairs(unit.stack) do
		
		if type(v.f) == "number" then
	
			table.insert(removeIndiz,i)
		end
	end
	for i=#removeIndiz,1,-1 do
		table.remove(unit.stack,removeIndiz[i])
	end

	return unit,factor
end

function LuaUnits:findMatchingUnit()
	local factor_s = 1
	local unit = self:copy()
	unit,factor_s = unit:simplify()

	if #unit.stack == 0 then 
		return LuaUnits:New(""),factor_s
	else
		for i,v in ipairs(LuaUnits.registeredUnits) do
			local iscompatible,factor = LuaUnits.compatible(unit,v)
			if iscompatible then
				return v, factor*factor_s
			end
		end
	end
	return unit,factor_s
end

function LuaUnits:isRegistered() 
	for i,v in ipairs(LuaUnits.registeredUnits) do
		if self.description == v.description then
			return true
		end
	end
	return false
end

function LuaUnits:unRegister() 
	self.description = ""
end

function LuaUnits:findCounterpart()
	for i=1,#self.stack do
		for j=1,#self.stack do
			if j~=i and self.stack[i].operation ~= self.stack[j].operation and self.stack[i].f == self.stack[j].f then
				return i,j
			end
		end
	end
	return nil,nil
end

function LuaUnits.getIndex(tab,entry)
	for i=1,#tab do
		if type(tab[i].f) == "table" then 
			if tab[i].f.description == entry.f.description and tab[i].operation == entry.operation then
				return i
			end
		else
			if tab[i].f == entry.f and tab[i].operation == entry.operation then
				return i
			end
		end
	end
	return nil
end

function LuaUnits.containsAll(tab,tabentry)
	for j=1, #tabentry do
		if LuaUnits.getIndex(tab,tabentry[j]) == nil then
			return false
		end
	end
	return true
end

function LuaUnits:unfold(recursive)
	local unfolded = self:unfoldComplete(recursive)

	local folded = {}
	local factor = 1
	for i=1,#unfolded do
		if getmetatable(unfolded[i].f) == LuaUnits then
			table.insert(folded,{["operation"]=unfolded[i].operation,["f"]=unfolded[i].f})
		else
			if unfolded[i].operation == "div" then
				factor = factor/unfolded[i].f
			elseif unfolded[i].operation == "mul" then
				factor = factor*unfolded[i].f
			end
		end
	end

	return factor,folded
end

function LuaUnits:getResultingFactor()
	local factor = 1
	for i=1,#self.stack do
		if type(self.stack[i].f) == "number" then
			if self.stack[i].operation == "div" then
				factor = factor/self.stack[i].f
			elseif self.stack[i].operation == "mul" then
				factor = factor*self.stack[i].f
			end
		end
	end
	return factor
end

function LuaUnits.compatible(unit1,unit2)
	
	local factor1_s = 1
	local factor2_s = 1

	unit1,factor1_s = unit1:simplify()
	unit2,factor2_s = unit2:simplify()

	local factor1,unfolded1 = unit1:unfold()
	local factor2,unfolded2 = unit2:unfold()
	
	factor1 = factor1 * factor1_s
	factor2 = factor2 * factor2_s


	if #unit1.stack == 0 then
		unfolded1 = {}
		table.insert(unfolded1,{["operation"]="mul",["f"]=unit1})
		factor1 = 1
	end

	if #unit2.stack == 0 then
		unfolded2 = {}
		table.insert(unfolded2,{["operation"]="mul",["f"]=unit2})
		factor2 = 1
	end
	
	for i,v in ipairs(unfolded1) do
		local index = LuaUnits.getIndex(unfolded2,v)
		
		if index then
			table.remove(unfolded2,index)
		else

			return false,nil
		end
	end

	if #unfolded2 == 0 then
		return true,factor1*factor2
	else
		return false,nil
	end
end

function LuaUnits.generateByString(unitString)
	local identifiers = {"%.","%/"}

	local unitsArray = {}
	local unitsOperation = {}

	while #unitString > 0 do

		local identifiers_index = {}
		for i,v in ipairs(identifiers) do
			local index = string.find(unitString, v)
			identifiers_index[i] = index
		end

		local minIndex = identifiers_index[1]
		local operation = "mul"

		if not minIndex then
			minIndex = identifiers_index[2]
			operation = "div"
		end
		for i,v in ipairs(identifiers_index) do
			if v ~= nil and (v<minIndex or minIndex == nil) then 
				minIndex = v 

				if i == 1 then

					operation = "mul"
				elseif i == 2 then
					operation = "div"
				end
			end
		end

		if not minIndex then break end

		local unitDesc = string.sub(unitString,1,minIndex-1)
		unitString = string.sub(unitString,minIndex+1,-1)
		table.insert(unitsArray,unitDesc)
		table.insert(unitsOperation,operation)

	end


	table.insert(unitsArray,unitString)


	if #unitsArray == 1 then	
		return LuaUnits.getByDescription(unitsArray[1])
	end

	local newunit = LuaUnits:New("")

	if tonumber(unitsArray[1]) then
		LuaUnits.pushOperation(newunit,"mul",tonumber(unitsArray[1]))
	elseif not LuaUnits.getByDescription() then
		LuaUnits.pushOperation(newunit,"mul",LuaUnits:New(unitsArray[1]):register())
	else
		LuaUnits.pushOperation(newunit,"mul",LuaUnits.getByDescription(unitsArray[1]))
	end
	for i=1,#unitsOperation do
		if tonumber(unitsArray[i+1]) then
			LuaUnits.pushOperation(newunit,unitsOperation[i],tonumber(unitsArray[i+1]))
		elseif not LuaUnits.getByDescription(unitsArray[i+1]) then
			LuaUnits.pushOperation(newunit,unitsOperation[i],LuaUnits:New(unitsArray[i+1]):register())
		else

			LuaUnits.pushOperation(newunit,unitsOperation[i],LuaUnits.getByDescription(unitsArray[i+1]))
		end
	end

	return newunit
end

function LuaUnits:generateString()
	local retString = ""
	if self.description ~= "" then
		return self.description
	end
	for i,v in ipairs(self.stack) do
		if type(v.f) == "table" then
			if v.operation == "mul" then
				retString = retString .. "." .. v.f.description
			elseif v.operation == "div" then
				retString = retString .. "/" .. v.f.description
			end
		end
	end
	if string.sub(retString,1,1) == "/" then
		return "1"..retString
	end
	return string.sub(retString,2,-1)
end

function LuaUnits:printStack()
	LuaUnits.printStackTable(self.stack)
end

function LuaUnits.printStackTable(tab)
	for i=1,#tab do
		local f_str = ""
		if type(tab[i].f) == "number" then
			f_str = tostring(tab[i].f)
		else
			f_str = tab[i].f.description
		end
		print(tab[i].operation .. "->" .. f_str)
	end
end

return LuaUnits