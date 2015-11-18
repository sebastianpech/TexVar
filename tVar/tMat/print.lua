----------------------------------------------------------------------------
-- print script
-- contains function for output and formatting
--
----------------------------------------------------------------------------

--- Call the number format function according to format definitions tMat
-- for every number in matrix
--
-- @return (String) formatted number as string with matrix enviroment
function tMat:pFormatVal()
  local ret = {}
  for j=1, self:size(1) do
    local row = {}
    for i=1, self:size(2) do
      row[i] = tVar.formatValue(self.numFormat,self.val[j][i].val,self.decimalSeparator)
    end
    ret[j] = table.concat(row,"&")
  end
  return "\\begin{pmatrix} ".. table.concat(ret,"\\\\") .. " \\end{pmatrix}"
end

function tMat.pFormatnameTexOutp(name)
  local loc_underline = string.find(name,"_")
  local loc_dunderline = string.find(name,"%^")

  if not loc_underline and not loc_dunderline then 
    return name
  end 
  if not loc_dunderline then
    name = string.gsub(name,"_","}_{")
  elseif not loc_underline then
    name = string.gsub(name,"%^","}^{")
  elseif loc_underline <= loc_dunderline then
      name = string.gsub(name,"_","}_{")
  else
      name = string.gsub(name,"%^","}^{")
  end
  return name
end

--- like pFormatVal but return varNames instead of values
--
-- @return (String) formatted with matrix enviroment
function tMat:pFormatnameTex()
  local ret = {}
  for j=1, self:size(1) do
    local row = {}
    for i=1, self:size(2) do
      if not (self.val[j][i].val and self.val[j][i].nameTex == "nil") then
        row[i] = self.val[j][i].nameTex
      else
        if tVar.coloredOuput then
          row[i] = "{\\color{red} undef}"
        else
          row[i] = "undef"
        end
      end 
    end
    ret[j] = table.concat(row,"&")
  end
  return "\\begin{pmatrix} ".. table.concat(ret,"\\\\") .. " \\end{pmatrix}"
end
--- create string with Name, Result, Equation, Numbers and Unit
-- 
-- @return (string) complete formula
function tMat:printFull()
  local eqSign = "&="
  if tVar.plainGroup then eqSign = "=" end

	local eqTexOutput = self.eqTex
	if self.eqTexAsMatrix then eqTexOutput = self.eqMat end
	if self.nameTex == "\\" .. self.texStyle .. "{" .. "}" then return eqTexOutput .. "=" .. self.eqNum .."=" .. self:pFormatVal() .. "~" .. self.unit end
	return self.nameTex .. eqSign .. eqTexOutput .. "=" .. self.eqNum .."=" .. self:pFormatVal() .. "~" .. self.unit
end
--- create string with Name, Result, Equation and Unit
-- 
-- @return (string) complete formula
function tMat:printHalf()
  local eqSign = "&="
  if tVar.plainGroup then eqSign = "=" end

	local eqTexOutput = self.eqTex
	if self.eqTexAsMatrix then eqTexOutput = self.eqMat end
	if self.nameTex == "\\" .. self.texStyle .. "{" .. "}" then return eqTexOutput .. "=" .. self:pFormatVal().. "~" .. self.unit end
	return self.nameTex .. eqSign .. eqTexOutput .. "=" .. self:pFormatVal().. "~" .. self.unit
end

--- create string with Name, Result, Equation and Unit
-- 
-- @return (string) complete formula
function tMat:printEQ()
  local eqSign = "&="
  if tVar.plainGroup then eqSign = "=" end

  local eqTexOutput = self.eqTex
  if self.eqTexAsMatrix then eqTexOutput = self.eqMat end
  if self.nameTex == "\\" .. self.texStyle .. "{" .. "}" then return eqTexOutput  end
  return self.nameTex .. eqSign .. eqTexOutput
end

--- create string with Name, Result, Equation and Unit
-- 
-- @return (string) complete formula
function tMat:printN()
  local eqSign = "&="
  if tVar.plainGroup then eqSign = "=" end
  
  local eqTexOutput = self.eqTex
  if self.eqTexAsMatrix then eqTexOutput = self.eqMat end
  if self.nameTex == "\\" .. self.texStyle .. "{" .. "}" then return eqTexOutput .. "=" .. self:pFormatVal() .. "~" .. self.unit end
  return self.nameTex .. eqSign .. self:pFormatVal() .. "~" .. self.unit
end