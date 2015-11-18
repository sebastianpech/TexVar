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
  if (getmetatable(a) == tVec and getmetatable(b) == tVec) then
    --falls beide Matrizen
    --kontrolle ob gleiche anzahl zeilen und spalten

    if(a:size(1) ~= b:size(1)) then 
      -- trying normal matrix multiplikation
      ans = tVar:New(tVar.matrix.mul(tMat.converttVartoNumber(a.val),tMat.converttVartoNumber(b.val))[1][1],"ANS")
    else
      ans = tVar:New((tVar.matrix.mul(tVar.matrix.transpose(tMat.converttVartoNumber(a.val)),tMat.converttVartoNumber(b.val)))[1][1],"ANS")
    end
  elseif ((getmetatable(a) == tVec or getmetatable(a) == tMat) and (getmetatable(b) == tVec or getmetatable(b) == tMat)) then
    local calcVal = (tVar.matrix.mul(tMat.converttVartoNumber(a.val),tMat.converttVartoNumber(b.val)));
    ans = tMat:New(calcVal,"ANS")
    if ans:size(1) == 1 and ans:size(2) == 1 then
      ans = tVar:New(calcVal,"ANS")
    elseif ans:size(1) == 1 or ans:size(2) == 1 then
      ans = tVec:New(calcVal,"ANS")
    end
  else
    local mat = tVec:New({},"")
    local scale = tVar:New(0,"")

     if (getmetatable(a) == tVec or getmetatable(a) == tMat) then
      mat = a
      scale = b
    else
      mat = b
      scale = a
    end

    ans.val = tMat.CheckTable(tVar.matrix.mulnum(tMat.converttVartoNumber(mat.val),scale.val))
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
  if(getmetatable(self) == tVec and getmetatable(_b) == tVec) then
    if(self:size(1) ~= _b:size(1)) then error ("Vektor dimensions do not match") end
    ans.val = tMat.CheckTable(tVar.matrix.cross(tMat.converttVartoNumber(self.val),tMat.converttVartoNumber(_b.val)))
  else
    error("Two Vectors needed")
  end
  ans.eqTex = self.nameTex .. " \\times " .. _b.nameTex
  ans.eqNum = self.eqNum .. " \\times " .. _b.eqNum
  ans.eqMat = (a.eqMat or a.nameTex) .. " \\times " .. (b.eqMat or b.nameTex)
  ans.nameTex = ans.eqTex
  return ans
end