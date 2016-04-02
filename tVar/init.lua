----------------------------------------------------------------------------
-- tVar init script
-- Load required modules
----------------------------------------------------------------------------

require "tVar.tVar_sub.core"

tVar.units = require "tVar.lib.units"

require("tVar.lib.unit_definitions")
require "tVar.tUnit"

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


tVar.Version = "1.5.18 alpha"

if _VERSION ~= "Lua 5.1" then
	loadstring = load
end
