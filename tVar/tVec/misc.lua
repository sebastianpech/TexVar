---------------------------------------------------------------------------
-- misc script
-- contains function not intend to be used by users
--
----------------------------------------------------------------------------

--- create a copy of a vector to remove pointers on table
--
-- @return (tVec) copy
function tVec:copy()
  local ret = tVec:New({},self.nameTex)
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