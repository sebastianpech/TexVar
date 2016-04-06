----------------------------------------------------------------------------
-- core script
-- creates the basic object and the New-Function
--
----------------------------------------------------------------------------

--- Matix Modul
-- Initialize tMat as empty tVar table
--
-- @param texStyle (string) defines display of matrices as variable i.e. bold
-- @param eqTexAsMatrix (boolean) enables ord disables equation view as matrix or as variable
tMat = tVar:New(0,"")
tMat.texStyle = function()
	return tVar.MATtexStyle	
end

tMat.eqTexAsMatrix = function()
		return tVar.eqTexAsMatrix
end
	
--- overrides the tVal:New function with new special metatables for matrices
--
-- @param _val (2dim array) style {{r1c1,r1c2,r1c3},{r2c1,r2c2,r2c3}}
-- @param _nameTex (string) LaTeX representation
function tMat:New(_val,_nameTex)
	local ret = {}
	setmetatable(ret,self)
	self.__index = self.getMatrixVal
	self.__add = self.mAdd
	self.__sub = self.mSub
	self.__mul = self.mMul
	self.__div = self.mDiv
	self.__unm = self.mNeg
	self.__concat = self.concatnameTex
	self.__newindex = self.setMatrixVal
	
	-- convert values to tVar objects
	ret.val = tMat.CheckTable(_val)

	if _nameTex == nil then
		ret.nameTex = ret:pFormatVal()
	else
		local _,count = _nameTex:gsub("\\\\" .. self.texStyle() .. "{.*}","")
		if counter == 0 then 
			ret.nameTex = "\\" .. self.texStyle() .. "{" .. _nameTex .. "}" 
		else
			ret.nameTex = _nameTex
		end
	end

	--ret.nameTex = tMat.pFormatnameTexOutp(ret.nameTex)
	ret.eqNum = ret:pFormatVal()
	ret.eqTex = ret.eqNum
	ret.eqMat = ret:pFormatnameTex()
	return ret
end

--- translate every acces to undefined object to set method
--
-- @param table self
-- @param key in table
-- @param value
function tMat.setMatrixVal(table,key,value)
	if type(key) == "string" then
		if key:find("^[0-9:(end)]+,[0-9:(end)]+$") or key:find("^[0-9:(end)]+$") then
			local r_start,r_end,c_start,c_end = tMat.getRange(table,key)

			if getmetatable(value) == tMat or getmetatable(value) == tVec then
				value = value.val
			end

			if type(value) ~= "table" then
				value = {{value}}
			elseif type(value[1]) ~= "table" then
				value = {value}
			end

			local tempVal = table.val

			for r = 0,r_end-r_start do
				for c=0,c_end-c_start do
					tempVal[r_start+r][c_start+c] = tVar.Check(value[r+1][c+1])
				end
			end

			rawset(table, "val", tempVal)
		else
			rawset(table, key, value)
		end
	else
		rawset(table, key, value)
	end
end
--- Metamethod for __index
--
-- can return indices from stringvalues
-- @param table self
-- @param key in table
function tMat.getMatrixVal(table,key)
	if type(key) == "string" then
		if key:find("^[0-9:(end)]+,[0-9:(end)]+$") or key:find("^[0-9:(end)]+$") then

		local r_start,r_end,c_start,c_end = tMat.getRange(table,key)
		-- create new matrix return element
		local val = {}
		
		for r = 0,r_end-r_start do
			val[r+1] = {}
			for c=0,c_end-c_start do
				val[r+1][c+1] = table.val[r_start+r][c_start+c]
			end
		end

		if #val[1] == 1 and #val == 1 then
			return tVar:New(val[1][1].val,table.nameTex .. "[\\text{" .. string.gsub(string.gsub(key,"\"",""),"'","") .. "}]")
		elseif #val[1] == 1 or #val == 1 then
			local ans = tVec:New(nil,table.nameTex .. "[\\text{" .. string.gsub(string.gsub(key,"\"",""),"'","") .. "}]")
			ans.val = val
			ans.eqTex = table.nameTex .. "[\\text{" .. string.gsub(string.gsub(key,"\"",""),"'","") .. "}]"
			ans.eqNum = ans:pFormatVal()
			ans.eqMat = ans:pFormatnameTex()
			return ans
		else
			return tMat:New(val,table.nameTex .. "[\\text{" .. string.gsub(string.gsub(key,"\"",""),"'","") .. "}]")
		end
	else

		return getmetatable(table)[key]
	end
	else
		return getmetatable(table)[key]
	end
end

--- Konvert strig matrix key to table ranges
--
-- @param table
-- @param key (string)
-- @return r_start (number)
-- @return r_end (number)
-- @return c_start (number)
-- @return c_end (number)
function tMat.getRange(table,key)
	local max_r = table:size(1)
	local max_c = table:size(2)

	if key:match(".+,") == nil and getmetatable(table) == tVec then
		return key,key,1,1
	end

	-- split at , remove , substitute end with max val
	local accespam_r = ((key:match(".+,")):sub(1,-2)):gsub("end",max_r)
	local accespam_c = ((key:match(",.+")):sub(2,-1)):gsub("end",max_c)
	
	-- replace : with 1:max val
	if accespam_r == ":" then accespam_r = "1:" .. max_r end
	if accespam_c == ":" then accespam_c = "1:" .. max_c end

	-- strip start end value
	local r_start = accespam_r:match(".:")
	local r_end = accespam_r:match(":.")
	if not r_start then
		r_start = accespam_r
		r_end = accespam_r
	else
		r_start = r_start:sub(1,-2)
		r_end = r_end:sub(2,-1)
	end

	local c_start = accespam_c:match(".:")
	local c_end = accespam_c:match(":.")
	if not c_start then
		c_start = accespam_c
		c_end = accespam_c
	else
		c_start = c_start:sub(1,-2)
		c_end = c_end:sub(2,-1)
	end

	return r_start,r_end,c_start,c_end
end