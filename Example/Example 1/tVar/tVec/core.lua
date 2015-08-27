----------------------------------------------------------------------------
-- core script
-- creates the basic object and the New-Function
--
----------------------------------------------------------------------------
--- Vector Modul
-- Initialize tVec as empty tMat table
--
-- @param texStyle (string) defines display of matrices as variable i.e. bold
tVec = tMat:New({},"")
tVec.texStyle = "vec"
--- overrides the tMat:New function with new special metatables for matrices
--
-- @param _val (2dim array) style {{r1c1,r1c2,r1c3},{r2c1,r2c2,r2c3}}
-- @param _nameTex (string) LaTeX representation
function tVec:New(_val,_nameTex,displayasmat)
  local ret = {}

  setmetatable(ret,self)
  self.__index = self
  self.__add = self.mAdd
  self.__sub = self.mSub
  self.__mul = self.mMul
  self.__div = self.mDiv
  self.__unm = self.mNeg
  --self.__tostring = self.Print
  ret.val = {}
  for i=1,#_val do
    ret.val[i] = {_val[i]}
  end
  ret.nameTex = _nameTex
  if displayasmat or displayasmat == nil then ret.nameTex = "\\" .. self.texStyle .. "{" .. _nameTex .. "}" end
  ret.eqNum = ret:pFormatVal()
  return ret
end