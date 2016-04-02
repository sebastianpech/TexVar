--[[
Units - Version 0.0.1 alpha

DESCRIPTION
	Units is a library to do calculations based on units.
EXAMPLE
	units = require("units")

	dofile("unit_definitions.lua")

	local u = units.fromString("kN/(m.cm)")

	u_ret=units("Pa"):convert(u)

	print("Conversionfactor is: ",u_ret.factor) -- Conversionfactor is: 	100000
	print("New Unit is: ",u_ret.unit:toString()) -- New Unit is: 	\frac{kN}{m.cm}
API
	--creation
		units.fromString([string]) -- use . for multiplication, / for division and () as brackets
		units([string] optional) -- create a new unit or call a unit incase it was added
		[units]:addUnit([string]) -- add unit to global stack for later reference
	
	--operations
		[units]:mul(factor,[units] optional) -- multiplies self with new factor and unit
		[units]:div(factor,[units] optional)
		[units]:add(scale) -- adds a scale to units
		[units]:root(scale)
		
	-- calculation
		[units]:compatible([unit]) -- check if two units are compatible returns true or false
		[units]:convert([unit]) -- tries to convert self to new unit
		-- returns named values: [return].unit and [return].factor
		[units]:tryConvert([unit],[unit],...) -- tries to convert self to new unit
		-- returns named values: [return].unit and [return].factor
		
	-- output
		[units]:printStack() -- prints the complete creation history of self (debug purposes)
		[units]:toString() -- returns LaTeX formatted unit
		
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
local units = {
	["unitset"] = {},
	["__call"] = function(self,identifier)

		if identifier and self.containsIdentifier(identifier) then
			return self.getByIdentifier(identifier)
		end

		local new = {}
		setmetatable(new,self)
		new.identifier = identifier

		new.stack = {}

		if identifier then
			new:addUnit()
		end
		return new
	end,
	["__index"] = function(table,field)
		return rawget(getmetatable(table),field)
	end,
	["operations"] = {
		["mul"] = "mul",
		["div"] = "div",
		["add"] = "add",
		["root"] = "root",
	}
}
setmetatable(units,units)

do -- stack functions 
	function units.containsIdentifier(identifier)
		return units.unitset[identifier] ~= nil
	end

	function units.getByIdentifier(identifier)
		return units.unitset[identifier]
	end

	function units.addUnit(self,identifier)
		identifier = self.identifier or identifier
		if not self then
			error("Error in function units.addIdentifier: unit nil")
		elseif units.containsIdentifier(identifier) then
			error("Error in function units.addIdentifier: identifier "..tostring(identifier).." already contained in set")
		elseif not identifier then
			error("Error in function units.addIdentifier: identifier not defined")
		else
			self.identifier = identifier
			units.unitset[self.identifier] = self
		end
	end

	function units:iterateStack()
		local index = 0
		local n=#self.stack
		local returnedN = false
		return function ()
			if n == 0 and not returnedN then 
				returnedN = true
				return 1,{
					["unit"] = self,
					["factor"] = 1,
					["operation"] = units.operations.mul
				}
			end
			index = index + 1
			if index <= n then
				return index,self.stack[index]
			end
			return nil
		end
	end

	function units:isLeaf()
		return #self.stack==0
	end

	function units:istLastBranch()
		if self:isLeaf() then return false end
		for i,v in self:iterateStack() do
			if #v.unit.stack > 0 then return false end
		end
		return true
	end

	function units:istLastBranchEx()
		if self:isLeaf() then return false end
		for i,v in self:iterateStack() do
			if #v.unit.stack > 0 and (v.operation == units.operations.mul or v.operation == units.operations.div) then
				return false
			end
		end
		return true
	end
	
	function units:istLastBranchEx2()
		if self:isLeaf() then return false end
		for i,v in self:iterateStack() do
			if #v.unit.stack > 0 and (v.operation == units.operations.mul or v.operation == units.operations.div) then
				if v.unit.identifier == nil and v.factor == 1 then
					for j,w in v.unit:iterateStack() do
						if #w.unit.stack > 0 and (w.operation == units.operations.mul or w.operation == units.operations.div) then
							return false 
						end
					end
				else
					return false
				end
			end
		end
		return true
	end
	
	function units:printStack(layer)
		layer = layer or 0
		if layer == 0 then
			print(self.identifier)
		end
		for i,v in self:iterateStack() do
			print(string.rep("\t",layer),v.operation,v.factor,v.unit.identifier)
			if not v.unit:isLeaf() then
				v.unit:printStack(layer+1)
			end
		end
	end

	function units:copy()
		local copy = units()
		copy.identifier = self.identifier
		if #self.stack == 0 then
			return copy
		end
		for i,v in self:iterateStack() do
			if v.unit:isLeaf() then
				table.insert(copy.stack,v)
			else
				local subcopy = v.unit:copy()
				table.insert(copy.stack,{
						["unit"] = subcopy,
						["factor"] = v.factor,
						["operation"] = v.operation
					})
			end
		end
		return copy
	end
end

do -- calculations
	function units:pushInlineOperation(factor,unit,operation)
		unit = unit or units("")
		local new = units()
		local maxi
		if self.identifier and units.containsIdentifier(self.identifier) then
			new.stack[#new.stack+1] = {
				["unit"] = self,
				["factor"] = 1,
				["operation"] = units.operations.mul
			}
		else
			for i,v in self:iterateStack() do
				new.stack[#new.stack+1] = {
					["unit"] = v.unit,
					["factor"] = v.factor,
					["operation"] = v.operation
				}
			end
		end
		new.stack[#new.stack+1] = {
			["unit"] = unit,
			["factor"] = factor,
			["operation"] = operation
		}
		return new
	end

	function units:pushBranchOperation(scale,operation)
		local new = units()
		new.stack[1] = {
			["unit"] = self,
			["factor"] = scale,
			["operation"] = operation
		}
		return new
	end

	-- mapper functions
	function units:mul(factor,unit)
		return self:pushInlineOperation(factor,unit,units.operations.mul)
	end

	function units:div(factor,unit)
		return self:pushInlineOperation(factor,unit,units.operations.div)
	end

	function units:add(scale)
		return self:pushBranchOperation(scale,units.operations.add)
	end

	function units:sub(scale)
		return self:pushBranchOperation(-scale,units.operations.add)
	end

	function units:root(scale)
		return self:pushBranchOperation(scale,units.operations.root)
	end
end

do -- simplifiation
	function units:simplify()
		local copy,factor = self:copy():unfold():summarizeFactors()
		return copy:clean():cancel():unfoldSqrt():cancel():cancelRoot():cancelAdd(),factor
	end

	function units:simplifynoCancel()
		local copy,factor = self:copy():unfold():summarizeFactors()
		return copy:clean():unfoldSqrt():cancelRoot():cancelAdd(),factor
	end

	function units:clean()
		local copy = units()
		copy.identifier = self.identifier
		for i,v in self:iterateStack() do
			if v.factor == 1 and (v.unit.identifier == nil or v.unit.identifier == "") and v.unit:isLeaf() and (v.operation == units.operations.mul or v.operation == units.operations.div) then
			elseif v.unit:isLeaf() then
				table.insert(copy.stack,v)
			else
				local subcopy = v.unit:clean()
				table.insert(copy.stack,{
						["unit"] = subcopy:copy(),
						["factor"] = v.factor,
						["operation"] = v.operation
					})
			end
		end
		return copy
	end

	function units:cancel()
		local indices = {}
		local ret = units()
		for j,w in self:iterateStack() do
			if w.operation == units.operations.mul and w.unit.identifier and w.unit.identifier ~= "" then
				indices[w.unit.identifier] = (indices[w.unit.identifier] or 0) + 1
			elseif w.operation == units.operations.div and w.unit.identifier and w.unit.identifier ~= "" then
				indices[w.unit.identifier] = (indices[w.unit.identifier] or 0) - 1
			else
				if not w.unit:isLeaf() then
					ret.stack[#ret.stack+1] = {
						["unit"] = w.unit:cancel(),
						["factor"] = w.factor,
						["operation"] = w.operation
					}
				else
					ret.stack[#ret.stack+1] = {
						["unit"] = w.unit:copy(),
						["factor"] = w.factor,
						["operation"] = w.operation
					}
				end
			end
		end
		
		function units:cancelAdd()
			local ret 
		
			local ignore = {}
			ret = units()
			for j,w in self:iterateStack() do
				if ignore[j] then
				elseif w.operation == units.operations.mul and w.unit:istLastBranchEx() then
					for i,v in self:iterateStack() do
						if  j ~= i and v.operation == units.operations.div then
								if v.unit:compatible(w.unit) then 
									changes = true
									ignore[j] = true
									ignore[i] = true
									break;
								end
						end
					end
				elseif w.unit:isLeaf() then
					table.insert(ret.stack,{
							["unit"] = w.unit:copy(),
							["factor"] = w.factor,
							["operation"] = w.operation
					})
				else
					
					table.insert(ret.stack,{
							["unit"] = w.unit:cancelAdd(),
							["factor"] = w.factor,
							["operation"] = w.operation
					})
				end
			end
			return ret
		end

		local removed = {}
		for i,v in pairs(indices) do
			if v ~= 0 then
				local operation = units.operations.mul
				if v<0 then
					operation = units.operations.div
				end
				for j=1,math.abs(v) do
					ret.stack[#ret.stack+1] = {
						["unit"] = units(i):copy(),
						["factor"] = 1,
						["operation"] = operation
					}
				end
			end
		end
		return ret
	end



	function units:cancelRoot()
		local ret = units()
		local unit = self:copy()
		local indices_ignore = {}
		for i,v in self:iterateStack() do
			if indices_ignore[i] then
			elseif v.operation == units.operations.root then
				local indices = {}
				local counter = 0
				for j,w in self:iterateStack() do
					if w.operation == units.operations.root and i ~= j and w.unit:compatible(v.unit) and w.factor == v.factor then
						indices[j] = true
						counter = counter + 1
					end
				end
				if v.factor - 1 == counter then
					for j,w in v.unit:iterateStack() do
						table.insert(ret.stack,{
								["unit"] = w.unit:copy(),
								["factor"] = w.factor,
								["operation"] = w.operation
							})
					end
					for index,_ in pairs(indices) do indices_ignore[index] = true end
				else
					table.insert(ret.stack,{
							["unit"] = v.unit,
							["factor"] = v.factor,
							["operation"] = v.operation
						})
				end
			elseif not v.unit:isLeaf() then
				table.insert(ret.stack,{
						["unit"] = v.unit:cancelRoot(),
						["factor"] = v.factor,
						["operation"] = v.operation
					})
			else
				table.insert(ret.stack,{
						["unit"] = v.unit,
						["factor"] = v.factor,
						["operation"] = v.operation
					})
			end
		end
		return ret
	end

	function units:summarizeFactors()
		local ret,factor = self:summarizeFactors_rec()
		return ret,factor
	end

	function units:summarizeFactors_rec()
		local retfactor = 1
		local new=units()

		for i,v in self:iterateStack() do
			if v.unit:isLeaf() then
				if v.operation == units.operations.div then
					retfactor = retfactor / v.factor
				elseif v.operation == units.operations.mul then
					retfactor = retfactor * v.factor
				end
				new.stack[#new.stack+1] = {
					["unit"] = v.unit:copy(),
					["factor"] = 1,
					["operation"] = v.operation
				}
			else
				local subunit,subfactor = nil,1
				subunit,subfactor = v.unit:summarizeFactors_rec()
				new.stack[#new.stack+1] = {
					["unit"] = subunit,
					["factor"] = 1,
					["operation"] = v.operation
				}
				if v.operation == units.operations.div then
					retfactor = retfactor / (v.factor*subfactor)
				elseif v.operation == units.operations.mul then
					retfactor = retfactor * (v.factor*subfactor)
				elseif v.operation == units.operations.root then
					retfactor = retfactor * math.sqrt(subfactor,v.factor)
					new.stack[i].factor = v.factor
				elseif v.operation == units.operations.add then
					retfactor = retfactor * subfactor
					new.stack[i].factor = v.factor/subfactor
				end
			end
		end
		return new,retfactor
	end


	local function mod(a,b) return a - math.floor(a/b)*b end
	function units:unfoldSqrt()

		local changes = true
		while changes do
			local ret = units()
			changes = false
			for i,v in self:iterateStack() do
				if v.unit:istLastBranch() and v.operation == units.operations.root then

					local notUnfolded = units()
					local indices={}
					for j,w in v.unit:iterateStack() do
						if w.operation == units.operations.mul and w.unit.identifier and w.unit.identifier ~= "" then
							indices[w.unit.identifier] = (indices[w.unit.identifier] or 0) + 1
						elseif w.operation == units.operations.div and w.unit.identifier and w.unit.identifier ~= "" then
							indices[w.unit.identifier] = (indices[w.unit.identifier] or 0) - 1
						end
					end
					local removed = {}
					for j,w in pairs(indices) do
						if w ~= 0 then
							local operation = units.operations.mul
							if w<0 then
								operation = units.operations.div
							end
							if mod(math.abs(w),v.factor) == 0 then
								changes = true
								for k=1,math.abs(w)/v.factor do
									ret.stack[#ret.stack+1] = {
										["unit"] = units(j):copy(),
										["factor"] = 1,
										["operation"] = operation
									}
								end
							else
								for k=1,math.abs(w) do
									notUnfolded.stack[#notUnfolded.stack+1] = {
										["unit"] = units(j):copy(),
										["factor"] = 1,
										["operation"] = operation
									}
								end
							end
						end
					end
					if #notUnfolded.stack > 0 then
						ret.stack[#ret.stack+1] = {
							["unit"] = notUnfolded:copy(),
							["factor"] = v.factor,
							["operation"] = v.operation
						}
					end
				elseif not v.unit:isLeaf() then
					ret.stack[#ret.stack+1] = {
						["unit"] = v.unit:unfoldSqrt(),
						["factor"] = v.factor,
						["operation"] = v.operation
					}
				else
					ret.stack[#ret.stack+1] = {
						["unit"] = v.unit,
						["factor"] = v.factor,
						["operation"] = v.operation
					}
				end
			end
			self = ret:copy()
		end
		return self
	end
	
	function units:unfold()
		selfcp = self:copy()
		local getOper = function (parentOper,currentOper)
			if parentOper == units.operations.mul then return currentOper end
			if parentOper == units.operations.div and currentOper == units.operations.div then return units.operations.mul end
			if parentOper == units.operations.div and currentOper == units.operations.mul then return units.operations.div end
		end
		
		local changes = true
		local counter = 1
		local counterMax = 100
		local new
		while changes and counter < counterMax do
			new = units()
			
			changes = false
			counter = counter + 1
			
			for i,v in selfcp:iterateStack() do
				if not v.unit:isLeaf() and (v.operation == units.operations.mul or v.operation == units.operations.div) then
					
					for j,w in v.unit:iterateStack() do
						if (w.operation == units.operations.mul or w.operation == units.operations.div) then
							changes = true
							table.insert(new.stack,{
								["unit"] = w.unit:copy(),
								["factor"] = w.factor,
								["operation"] = getOper(v.operation,w.operation)
							})

						end
					end
          if v.factor ~= 1 then
            table.insert(new.stack,{
              ["unit"] = units(),
              ["factor"] = v.factor,
              ["operation"] = v.operation
            })
          end
        
					local new_sub = units()
					for j,w in v.unit:iterateStack() do
						if not (w.operation == units.operations.mul or w.operation == units.operations.div) then
							table.insert(new_sub.stack,{
								["unit"] = w.unit:copy(),
								["factor"] = w.factor,
								["operation"] = w.operation
							})
						end
					end
					if #new_sub.stack > 0 then
						table.insert(new.stack,{
								["unit"] = new_sub:copy(),
								["factor"] = v.factor,
								["operation"] = v.operation
						})
					end
					
				elseif not v.unit:isLeaf() then
					changes = true
					
					table.insert(new.stack,{
								["unit"] = v.unit:unfold():copy(),
								["factor"] = v.factor,
								["operation"] = v.operation
					})
				else
					table.insert(new.stack,{
								["unit"] = v.unit:copy(),
								["factor"] = v.factor,
								["operation"] = v.operation
					})
				end
			end
			selfcp = new:copy()
		end
		return new
	end
end

do -- unit specifics
	function units:getConversionFactor(unit)
		if self:compatible(unit) then
			local unitA,factorA = self:simplify()
			local unitB,factorB = unit:simplify()

			return factorB/factorA
		else
			return nil
		end
	end

	function units:compatible(unit)
		if not unit then unit = units() end
		local unitA,factorA = self:simplify()
		local unitB,factorB = unit:simplify()
		local unitA_copy = unitA:copy()
		local unitB_copy = unitB:copy()

		if #unitA.stack ~= #unitB.stack then
			return false
		elseif #unitA.stack == 0 and #unitB.stack == 0 and unitA.identifier == unitB.identifier then
			return true
		else

			for i=#unitB_copy.stack,1,-1 do
				local v=unitB_copy.stack[i]
				for j=#unitA_copy.stack,1,-1 do
					local w = unitA_copy.stack[j]
					if v.unit:isLeaf() and w.unit:isLeaf() then
						if w.operation == v.operation and w.factor == v.factor and w.unit.identifier == v.unit.identifier then
							table.remove(unitA_copy.stack,j)
							table.remove(unitB_copy.stack,i)
							break
						end
					elseif not (v.unit:isLeaf() and w.unit:isLeaf()) then
						if v.unit:compatible(w.unit) then
							table.remove(unitA_copy.stack,j)
							table.remove(unitB_copy.stack,i)
							break
						end
					end
				end
			end
		end

		if #unitA_copy.stack == 0 and #unitB_copy.stack == 0 then
			return true
		end
		return false
	end

	function units:tryConvert(unit)
		local newSecondary = self:copy()
		newSecondary = newSecondary:div(1,unit):simplify()
		newPrimary = unit:copy():mul(1,newSecondary)
		
		local factor = self:getConversionFactor(newPrimary)
		if factor then
			return {["unit"]=newPrimary,["factor"]=factor}
		end
		return {["unit"]=self,["factor"]=1}
	end

	function units:convert(unit)
		local factor = self:getConversionFactor(unit)
		if factor then
			return {["unit"]=unit,["factor"]=factor}
		end
		return nil
	end
	
	function units:replace(unit)
		local Searchunit,_ = unit:simplify()
		if Searchunit:isLeaf() or Searchunit:istLastBranch() then
			return self:replace1D(unit)
		else
			return self:replace2D(unit)
		end
	end

end


do -- String io
	function units:toString()
		unit = self:clean()
		local timesSaparator = "\\,"
		local retString = ""
		local divisorUsed = false
		local dividendUsed = false
		local divisor = ""
		local dividend = ""
		for i,v in unit:iterateStack() do

			if v.operation == units.operations.mul then
				dividendUsed = true
				if (v.unit:isLeaf() or units.containsIdentifier(v.unit.identifier))  then
					if not (v.unit.identifier == nil or v.unit.identifier == "") then
						dividend = dividend .. timesSaparator .. v.unit.identifier
					end
				else
					dividend = dividend ..timesSaparator.. v.unit:toString()
				end
			elseif v.operation == units.operations.div then
				divisorUsed = true
				if (v.unit:isLeaf() or units.containsIdentifier(v.unit.identifier))  then
					if not (v.unit.identifier == nil or v.unit.identifier == "") then
						divisor = divisor ..timesSaparator.. v.unit.identifier
					end
				else
					divisor = divisor ..timesSaparator.. v.unit:toString()
				end
			elseif v.operation == units.operations.root then
				dividendUsed = true
				dividend = dividend .. timesSaparator .. "\\sqrt["..v.factor.."]{"..v.unit:toString().."}"
			elseif v.operation == units.operations.add then
				dividendUsed = true
				local sign = " + "
				if v.factor < 0 then
					sign = " - "
				end
				dividend = dividend .. timesSaparator .. "("..v.unit:toString()..sign..v.factor..")"
			end
		end
		if string.sub(divisor,#timesSaparator+1) == "" then
			return string.sub(dividend,#timesSaparator+1)
		elseif string.sub(dividend,#timesSaparator+1) == "" then
			return "\\dfrac{1}{"..string.sub(divisor,#timesSaparator+1).."}"
			--return "1 \\per {"..string.sub(divisor,#timesSaparator+1).."}"
		else
			return "\\dfrac{"..string.sub(dividend,#timesSaparator+1).."}{"..string.sub(divisor,#timesSaparator+1).."}"
			--return "{"..string.sub(dividend,#timesSaparator+2).."} \\per {"..string.sub(divisor,#timesSaparator+2).."}"
		end
	end

	function units.fromString(string)
		if string == "" then return units() end
		local new = units()
		local operators = {
			["/"]=units.operations.div,
			["."]=units.operations.mul,
		}
		local bracket = {
			open = "(",
			close = ")"
		}

		local isOperator = function (char)
			for i,_ in pairs(operators) do
				if char == i then return true end
			end
			return false
		end

		local isBracket = function (char)
			for _,v in pairs(bracket) do
				if char == v then return true end
			end
			return false
		end

		local isSpecial = function (char) 
			return isOperator(char) or isBracket(char)
		end

		local getNext = function (pos)
			local index = pos or 1
			return function ()
				if index > #string then
					return nil
				else
					local toIndex = index-1
					repeat
						toIndex = toIndex + 1
						local curChar = string.sub(string,toIndex,toIndex)

					until isSpecial(curChar) or toIndex > #string
					if index == toIndex then
						toIndex = toIndex + 1
					end
					local retString = string.sub(string,index,toIndex-1)
					index = toIndex
					return retString
				end
			end
		end

		local bracketStack = {
			stack = {}
		}
		
		bracketStack.push = function (elem)
			table.insert(bracketStack.stack,elem)
		end
		bracketStack.pop = function()
			table.remove(bracketStack.stack)
		end
		bracketStack.get = function()
			return bracketStack.stack[#bracketStack.stack]
		end

		bracketStack.push(new)
		
		local newBranch2 = units()
		table.insert(bracketStack.get().stack,{
						["unit"] = newBranch2,
						["factor"] = 1,
						["operation"] = units.operations.mul
		})
		bracketStack.push(newBranch2)
		for elem in getNext() do
			if isOperator(elem) then
				local newBranch = units()

				table.insert(bracketStack.get().stack,{
						["unit"] = newBranch,
						["factor"] = 1,
						["operation"] = operators[elem]
					})

			bracketStack.push(newBranch)

			elseif isBracket(elem) then
				if elem == bracket.close then
					bracketStack.pop()
				else
					local newBranch = units()

					table.insert(bracketStack.get().stack,{
							["unit"] = newBranch,
							["factor"] = 1,
							["operation"] = units.operations.mul
						})

					bracketStack.push(newBranch)
				end
			elseif tonumber(elem) then
				
				table.insert(bracketStack.get().stack,{
						["unit"] = units(),
						["factor"] = elem,
						["operation"] = units.operations.mul
					})
				
				bracketStack.pop()
			else
				table.insert(bracketStack.get().stack,{
						["unit"] = units(elem),
						["factor"] = 1,
						["operation"] = units.operations.mul
					})
				bracketStack.pop()
			end
		end
		return new
	end
end

return units