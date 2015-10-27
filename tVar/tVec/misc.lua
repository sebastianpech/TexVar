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
  	ret.val[i][1] = self.val[i][1]:copy()
  end
  ret.eqNum = self.eqNum
  ret.eqMat = self.eqMat
  ret.eqTex = self.eqTex
  return ret
end