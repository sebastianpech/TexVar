----------------------------------------------------------------------------
-- misc script
-- contains function not intend to be used by users
--
----------------------------------------------------------------------------

--- same setName as in tVar but uses param texStyle for formatting
--
-- @param _nameTex (string) LaTeX representation
-- @return self 
function tMat:setName(_nameTex)
	self.nameTex = tMat.pFormatnameTexOutp("\\" .. self.texStyle() .. "{" .. _nameTex .. "}")
	return self
end
--- create a copy of a matrix to remove pointers on table
--
-- @return (tMat) copy
function tMat:copy()
  local ret = tMat:New({},self.nameTex)
  for i=1,self:size(1) do
  	ret.val[i] = {}
  	for j=1,self:size(2) do
	  	ret.val[i][j] = self.val[i][j]:copy()
	end
  end
  ret.eqNum = self.eqNum
  ret.eqMat = self.eqMat
  ret.eqTex = self.eqTex
  return ret
end

--- returns the size of the matrix
--
-- @param rc (1 or 2) 1 is for row count 2 if for collumn count
-- @return (number)
function tMat:size(rc)
  if rc == 1 then return #self.val end
  return assert(#self.val[1],1)
end
--- sets unit of tVar object
--
-- @param _unit (string) Unit
-- @return self
function tMat:setUnit(_unit)
	for i=1,self:size(1) do
  	for j=1,self:size(2) do
	  	self.val[i][j]:setUnit(_unit)
		end
  end
	return self
end
--- sets text after unti of tVar object
--
-- @param _unit (string) Unit
-- @return self
function tMat:setUText(_text)
	for i=1,self:size(1) do
  	for j=1,self:size(2) do
	  	self.val[i][j]:setUText(_text)
		end
  end
	return self
end

--- Checks if overloaded param is tMat,tVec,tVar or not
-- if not for calculation purposes the overloaded param 
-- is converted to tVar and returned
-- eq number 17 is return as tVar:New(17,"17.0")
--
-- @param _a (tVar,tMat,tVec,number) param to be cecked
-- @param _nameTex (optonal,String) new nameTex for passed number 
-- @return (tVar) _a as tVar
function tMat.Check(_a,_nameTex)
  if(getmetatable(_a) == tVar or getmetatable(_a) == tMat or getmetatable(_a) == tVec) then return _a end
  ret = tVar:New(_a*1,tVar.formatValue(tVar.numFormat,_a,tVar.decimalSeparator))
  ret.eqTex = tVar.formatValue(tVar.numFormat,_a,tVar.decimalSeparator)
  if _nameTex then
  	ret.nameTex = _nameTex
  end
  return ret
end
--- converts every number in a table to tVar
--
-- @param _tab table mixed tVar and Number
-- @return table containing only tVar
function tMat.CheckTable(_tab)
	local tVarVal = {}
	for r=1,#_tab do
		tVarVal[r] = {}
		for c=1,#_tab[r] do
			tVarVal[r][c] = tVar.Check(_tab[r][c])
		end
	end
	return tVarVal
end
--- convert tVar Table to Number Table
--
-- @param tVarTable
-- @return Number table
function tMat.converttVartoNumber(tVarTable)
	local numberTable = {}
	for r=1, #tVarTable do
		numberTable[r] = {}
		for c=1, #tVarTable[r] do
			numberTable[r][c] = tVar.Check(tVarTable[r][c]).val
		end
	end
	return numberTable
end
--- function returns table of vlaues from tMAt objects
--
-- @param tMatTable (tMat table)
-- @return table of tMat.val
function tMat.valuesFromtVar(tMatTable)
	local ret = {}
	for i=1, #tMatTable do
		ret[i] = tMat.converttVartoNumber(tMatTable[i].val)
	end
	return ret
end