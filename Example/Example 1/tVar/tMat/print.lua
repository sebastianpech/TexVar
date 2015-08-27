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
      row[i] = tVar.formatValue(self.numFormat,self.val[j][i],self.decimalSeparator)
    end
    ret[j] = table.concat(row,"&")
  end
  return "\\begin{pmatrix} ".. table.concat(ret,"\\\\") .. " \\end{pmatrix}"
end