----------------------------------------------------------------------------
-- calculation script
-- Contains Metatables and Functions for calculation
--
----------------------------------------------------------------------------
--- Addition
-- Metatable
--
-- @param _a (tMat)
-- @param _b (tMat)
-- @return (tVar)
function tMat.mAdd(_a,_b)
  local ans = tMat:New({},"ANS")

  local a, b = tMat.Check(_a),tMat.Check(_b)
  -- ab hier a und b entweder tMat oder tVar

  if ((getmetatable(a) == tMat and getmetatable(b) == tMat) or (getmetatable(a) == tVec and getmetatable(b) == tMat) or (getmetatable(a) == tMat and getmetatable(b) == tVec) or (getmetatable(a) == tVec and getmetatable(b) == tVec)) then
    --falls beide Matrizen
    --kontrolle ob gleiche anzahl zeilen und spalten
    if(a:size(1) ~= b:size(1) or a:size(2) ~= b:size(2)) then error ("Matrix Dimensions do not match") end
    ans.val = tVar.matrix.add(a.val,b.val)
  else
    error("Can't perform operation Matrix + Skalar")
  end
  if(getmetatable(ans) == tMat) then
    if(ans:size(2) == 1) then
      local tempVal = ans.val
      ans = tVec:New({},"ANS")
      ans.val = tempVal
    end
  end
  ans.eqTex = a.nameTex .. "+" .. b.nameTex
  ans.eqNum = a.eqNum .. "+" .. b.eqNum
  ans.nameTex = ans.eqTex
  return ans
end
--- Substraction
-- Metatable
--
-- @param _a (tMat)
-- @param _b (tMat)
-- @return (tVar)
function tMat.mSub(_a,_b)
  local ans = tMat:New({},"ANS")

  local a, b = tMat.Check(_a),tMat.Check(_b)
  -- ab hier a und b entweder tMat oder tVar

  if ((getmetatable(a) == tMat and getmetatable(b) == tMat) or (getmetatable(a) == tVec and getmetatable(b) == tMat) or (getmetatable(a) == tMat and getmetatable(b) == tVec) or (getmetatable(a) == tVec and getmetatable(b) == tVec)) then
    --falls beide Matrizen
    --kontrolle ob gleiche anzahl zeilen und spalten
    if(a:size(1) ~= b:size(1) or a:size(2) ~= b:size(2)) then error ("Matrix Dimensions do not match") end
    ans.val = tVar.matrix.sub(a.val,b.val)
  else
    error("Can't perform operation Matrix + Skalar")
  end

  if(getmetatable(ans) == tMat) then
    if(ans:size(2) == 1) then
      local tempVal = ans.val
      ans = tVec:New({},"ANS")
      ans.val = tempVal
    end
  end
  ans.eqTex = a.nameTex .. "-" .. b.nameTex
  ans.eqNum = a.eqNum .. "-" .. b.eqNum
  ans.nameTex = ans.eqTex
  return ans
end
--- Multiplikation
-- matrix*scale = elementwise multiplikation
-- Metatable
--
-- @param _a (tMat,number)
-- @param _b (tMat,number)
-- @return (tMat)
function tMat.mMul(_a,_b)
  local ans = tMat:New({},"ANS")
  ans.nameTex = ""
  local a, b = tMat.Check(_a),tMat.Check(_b)
  -- ab hier a und b entweder tMat oder tVar
  if ((getmetatable(a) == tMat and getmetatable(b) == tMat) or (getmetatable(a) == tVec and getmetatable(b) == tMat) or (getmetatable(a) == tMat and getmetatable(b) == tVec) or (getmetatable(a) == tVec and getmetatable(b) == tVec)) then
    --falls beide Matrizen
    --kontrolle ob gleiche anzahl zeilen und spalten
    if(a:size(1) ~= b:size(2) or a:size(2) ~= b:size(1)) then error ("Matrix Dimensions do not match") end
    ans.val = tVar.matrix.mul(a.val,b.val)
  else
    local mat = tMat:New({},"")
    local scale = tVar:New(0,"")
    if (getmetatable(a) == tMat) then
      mat = a
      scale = b
    else
      mat = b
      scale = a
    end

    ans.val = tVar.matrix.mulnum(mat.val,scale.val)
  end
  if(getmetatable(ans) == tMat) then
    if(ans:size(2) == 1) then
      local tempVal = ans.val
      ans = tVec:New({},"ANS")
      ans.val = tempVal
    end
  end

  ans.eqTex = a.nameTex .. " \\cdot " .. b.nameTex
  ans.eqNum = a.eqNum .. " \\cdot " .. b.eqNum
  ans.nameTex = ans.eqTex
  return ans
end
--- Division
-- only matrix/scale = elementwise division
-- Metatable
--
-- @param _a (tMat,number)
-- @param _b (tMat,number)
-- @return (tMat)
function tMat.mDiv(_a,_b)
  local ans = tMat:New({},"ANS")

  local a, b = tMat.Check(_a),tMat.Check(_b)
  -- ab hier a und b entweder tMat oder tVar

  if ((getmetatable(a) == tMat and getmetatable(b) == tMat) or (getmetatable(a) == tVec and getmetatable(b) == tMat) or (getmetatable(a) == tMat and getmetatable(b) == tVec) or (getmetatable(a) == tVec and getmetatable(b) == tVec)) then
    error("Can't perform division of two Matrices")
  else
    local mat = tMat:New({},"")
    local scale = tVar:New(0,"")
    if (getmetatable(a) == tMat) then
      mat = a
      scale = b
    else
      mat = b
      scale = a
    end

    ans.val = tVar.matrix.divnum(mat.val,scale.val)
  end
  if(getmetatable(ans) == tMat) then
    if(ans:size(2) == 1) then
      local tempVal = ans.val
      ans = tVec:New({},"ANS")
      ans.val = tempVal
    end
  end
  ans.eqTex = "\\dfrac{" .. a.nameTex .. "}{" .. b.nameTex .. "}"
  ans.eqNum = "\\dfrac{" .. a.eqNum .. "}{" .. b.eqNum .. "}"
  ans.nameTex = ans.eqTex

  return ans
end
--- unary minus
-- Metatable
--
-- @param _a (tMat)
-- @return (tMat)
function tMat.mNeg(a)
  local ans = a*(-1)

  ans.eqTex = "-"..a.nameTex
  ans.eqNum = "-"..a.eqNum
  ans.nameTex = ans.eqTex
  return ans
end
--- Transpose
--
-- @return (tMat) Transposed
function tMat:T()
  local ans = self:copy()
  ans.val = tVar.matrix.transpose(self.val)

  ans.eqTex = self.nameTex .. "^\\top"
  ans.eqNum = self.eqNum  .. "^\\top"
  ans.nameTex = ans.eqTex
  return ans
end
--- Determinant
--
-- @return (tMat) Determinant
function tMat:Det()
  local ans = tVar:New(tVar.matrix.det(self.val),"ANS")

  ans.eqTex = "|" .. self.nameTex .. "|"
  ans.eqNum = "\\begin{vmatrix} " .. self.eqNum  .. "\\end{vmatrix} "
  ans.nameTex = ans.eqTex
  return ans
end
--- Inverse
--
-- @return (tMat) Inverse
function tMat:Inv()
  local ans = self:copy()
  ans.val = tVar.matrix.invert(self.val)

  ans.eqTex = self.nameTex .. "^{-1}"
  ans.eqNum = self.eqNum  .. "^{-1}"
  ans.nameTex = ans.eqTex
  return ans
end