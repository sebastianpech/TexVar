----------------------------------------------------------------------------
-- tVar init script
-- Load required modules
----------------------------------------------------------------------------

require "tVar.tVar.core"
require "tVar.tVar.misc"
require "tVar.tVar.calc"
require "tVar.tVar.print"

require "tVar.tMat.core"
require "tVar.tMat.misc"
require "tVar.tMat.calc"
require "tVar.tMat.print"

require "tVar.tVec.core"
require "tVar.tVec.calc"

require "tVar.constants"
require "tVar.misc"

require "tVar.plot"

--- Load external
--
-- luamatrix
tVar.matrix = require "tVar.lib.matrix"

tVar.Version = "1.5.2"

if _VERSION ~= "Lua 5.1" then
	loadstring = load
end
