----------------------------------------------------------------------------
-- core script
-- creates the basic object and the New-Function
--
----------------------------------------------------------------------------

--- Initialize tVar table
--
-- @param val (number) value of tVar
-- @param nameTex (string) LaTeX representation 
-- @param eqTex (string) equation for calculating val i.e. history
-- @param eqNum (string) equation for calculating val i.e. history with numbers
-- @param unit (string) is added after result with fixed space
-- @param numFormat (string) numberformat for displaying val
-- @param mathEnviroment (string) LaTeX math enviroment that is used for output
-- @param debugMode (string) if set to "on" every tex.print command is surrounded with \verb||
-- @param outputMode (string) can be RES for Result, RES_EQ form Result and Equation and RES_EQ_N form Result, Equation and Numbers. Controls the print() command
-- @param numeration (bool) turns equation numeration on and of. Controls the print() command
-- @param decimalSeparator (string) sets the decimalSeparatio i.e. ","
-- @param calcPrecision (number) ammount of decimal places
-- @param history_fun stores the tVar function for the result
-- @param history_arg stores the arguments used with history_fun
-- @param qOutput controls the output for q function
tVar = {
	val = nil,
	nameTex = "",
	eqTex = "",
	eqNum = "",
	unit = "",
	numFormat = "%.3f",
	mathEnviroment = "align",
	debugMode = "off",
	outputMode = "RES",
	numeration = true,
	decimalSeparator = ".",
	calcPrecision = 10,
	history_fun = nil,
	history_arg = {},
	qOutput = false
}
--- create new tVar object. tVar has all properties, functions and
-- metatables
-- 
-- @param _val (number) value of LaTeX Variable
-- @param _nameTex (string) LaTeX representation
-- @return (tVar) Number with LaTeX representation
function tVar:New(_val,_nameTex)
	local ret = {}
	setmetatable(ret,self)
	self.__index = self
	self.__add = self.Add
	self.__sub = self.Sub
	self.__mul = self.Mul
	self.__div = self.Div
	self.__pow = self.Pow
	self.__unm = self.Neg
	--self.__tostring = self.print
	self.__eq = self.Equal
	self.__lt = self.LowerT
	self.__le = self.LowerTE
	ret.val = _val
	ret.nameTex = _nameTex
	ret.eqNum = ret:pFormatVal()
	return ret
end
--- calculate result of history
--
-- @return result
function tVar:solve()
	
	if self.val ~= nil then return self end
	for i=1,#self.history_arg do
		self.history_arg[i]:solve()
	end
	self.val = self.history_fun(table.unpack(self.history_arg))
	return self
end