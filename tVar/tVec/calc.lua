----------------------------------------------------------------------------
-- calculation script
-- Contains Metatables and Functions for calculation
--
----------------------------------------------------------------------------

--- Multiplikation
-- Metatable
--
-- @param _a (tMat,number)
-- @param _b (tMat,number)
-- @return (tMat)
function tVec.mMul(_a,_b)
  local ans = tVec:New({},"ANS")
  ans.nameTex = ""
  local a, b = tVec.Check(_a),tVec.Check(_b)
  -- ab hier a und b entweder tMat oder tVar
  if (ismetatable(a,tVec) and ismetatable(b,tVec)) then
    --falls beide Matrizen
    --kontrolle ob gleiche anzahl zeilen und spalten

    if(a:size(1) ~= b:size(1)) then 
      -- trying normal matrix multiplikation
      ans = tVar:New(tVar.matrix.mul((a.val),(b.val))[1][1],"ANS")
    else
      ans = tVar:New((tVar.matrix.mul(tVar.matrix.transpose((a.val)),(b.val)))[1][1],"ANS")
    end
  elseif ((ismetatable(a,tVec) or ismetatable(a,tMat)) and (ismetatable(b,tVec) or ismetatable(b,tMat))) then
    local calcVal = (tVar.matrix.mul((a.val),(b.val)));
    ans = tMat:New(calcVal,"ANS")
    if ans:size(1) == 1 and ans:size(2) == 1 then
      ans = tVar:New(calcVal,"ANS")
    elseif ans:size(1) == 1 or ans:size(2) == 1 then
      ans = tVec:New(calcVal,"ANS")
    end
  else
    local mat = tVec:New({},"")
    local scale = tVar:New(0,"")

     if (ismetatable(a,tVec) or ismetatable(a,tMat)) then
      mat = a
      scale = b
    else
      mat = b
      scale = a
    end

    ans.val = tMat.CheckTable(tVar.matrix.mulnum((mat.val),scale))
  end

  ans.eqTex = a.nameTex .. " \\cdot " .. b.nameTex
  ans.eqNum = a.eqNum .. " \\cdot " .. b.eqNum
  ans.eqMat = (a.eqMat or a.nameTex) .. " \\cdot " .. (b.eqMat or b.nameTex)
  ans.nameTex = ans.eqTex
  return ans
end
--- Crossproduct
--
-- @param _b (tVec)
-- @return (tVec)
function tVec:crossP(_b)
  local ans = tVec:New({},"ANS")
  ans.nameTex = ""
  if(ismetatable(self,tVec) and ismetatable(_b,tVec)) then
    if(self:size(1) ~= _b:size(1)) then error ("Vektor dimensions do not match") end
    ans.val = tMat.CheckTable(tVar.matrix.cross((self.val),(_b.val)))
  else
    error("Two Vectors needed")
  end
  ans.eqTex = self.nameTex .. " \\times " .. _b.nameTex
  ans.eqNum = self.eqNum .. " \\times " .. _b.eqNum
  ans.eqMat = (self.eqMat or self.nameTex) .. " \\times " .. (_b.eqMat or _b.nameTex)
  ans.nameTex = ans.eqTex
  return ans
end

--- Compare Equal
-- Metatable
--
-- @param a (tVec,number)
-- @param b (tVec,number)
-- @return (Bool)
function tVec.Equal(a,b)
	if tVar.roundValToPrec(a) == tVar.roundValToPrec(b) then return true end
	return false
end