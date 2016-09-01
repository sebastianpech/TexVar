----------------------------------------------------------------------------
-- tVar init script
-- Load required modules
----------------------------------------------------------------------------
require "tVar.tVar_sub.core"

require "tVar.tVar_sub.misc"
require "tVar.tVar_sub.calc"
require "tVar.tVar_sub.print"

require "tVar.tMat.core"
require "tVar.tMat.misc"
require "tVar.tMat.calc"
require "tVar.tMat.print"

require "tVar.tVec.core"
require "tVar.tVec.calc"
require "tVar.tVec.misc"

require "tVar.constants"
require "tVar.misc"
require "tVar.interpreter"

require "tVar.plot"


--- Load external
--
-- luamatrix
tVar.matrix = require "tVar.lib.matrix"

math.old_abs = math.abs
math.abs = function (val)
	if getmetatable(val) == tVar then
		return tVar.abs(val)
	else
		return math.old_abs(val)
	end
end

tVar.matrix.copy = function (m)
		return m
end

tVar.Version = "1.5.20"

--- Lua 5.2 Functions Available for 5.1
-- @section lua52

--- pack an argument list into a table.
-- @param ... any arguments
-- @return a table with field n set to the length
-- @return the length
-- @function table.pack
if not table.pack then
    function table.pack (...)
        return {n=select('#',...); ...}
    end
end

if not table.unpack then
	table.unpack = unpack
end
if _VERSION ~= "Lua 5.1" then
	loadstring = load
end
