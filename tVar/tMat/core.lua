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
tMat.texStyle = "mathbf"
tMat.eqTexAsMatrix = false
	
--- overrides the tVal:New function with new special metatables for matrices
--
-- @param _val (2dim array) style {{r1c1,r1c2,r1c3},{r2c1,r2c2,r2c3}}
-- @param _nameTex (string) LaTeX representation
function tMat:New(_val,_nameTex)
	local ret = {}
	setmetatable(ret,self)
	self.__index = self
	self.__add = self.mAdd
	self.__sub = self.mSub
	self.__mul = self.mMul
	self.__div = self.mDiv
	self.__unm = self.mNeg
	self.__concat = self.concatnameTex
	
	-- convert values to tVar objects
	ret.val = tMat.CheckTable(_val)
	ret.nameTex = "\\" .. self.texStyle .. "{" .. _nameTex .. "}"
	ret.eqNum = ret:pFormatVal()
	ret.eqTex = ret.nameTex
	ret.eqMat = ret:pFormatnameTex()
	return ret
end