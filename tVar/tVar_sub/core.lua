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
-- @param disableOutput disables all output
-- @param coloredOuput enables disables printing nil variables in red
-- @param autocutZero (boolean) remove zeros after last decimal number
-- @param autoprint (boolean) automatically print all operations
-- @param logInterp (boolean) log interpreted files
-- @param outputFunction (table, string) all possible output functions as string 
tVar = {
	val = nil,
	nameTex = "",
	eqTex = "",
	eqNum = "",
	unit = nil,
	prefUnit = nil,
	utext = nil,
	numFormat = "%.3f",
	mathEnviroment = "align",
	debugMode = "off",
	outputMode = "RES_EQ_N",
	numeration = true,
	decimalSeparator = ".",
	calcPrecision = 10,
	history_fun = nil,
	history_arg = {},
	qOutput = false,
	disableOutput = false,
	coloredOuput = false,
	autocutZero = true,
	autocutDecimalSep = true,
	autoprint = true,
	logInterp = false,
	outputFunction = {":print",":outRES",":outEQ",":outRES_EQ",":outRES_EQ_N",":out"},
	ignoreInterpFunctions = {},
	firstInGroup = false,
	plainGroup = false,
	unitCommand = "\\si",
	interpretedShowOutput = false,
	useUnits = true,
	N_outputInBaseUnits = true,
	N_outputWithUnits = false,
	MatrixShowUnits = false,
	MATtexStyle = "mathbf",
	VECtexStyle = "vec",
	eqTexAsMatrix = false,
	gnuplot_library = "gnuplot",
	gnuplot_terminal = "postscript eps enhanced color font 'Helvetica,12'",
	gnuplot_file_extensions = "eps",
}
mt={}

--- maps intString to call metamethode
--
--@param _ table
--@param _string
function  mt.__call(_,_string)
	tVar.intString(_string)
end
mt.__index = function(table, key)
	if tVar.mapping[key] then
		return rawget(table,tVar.mapping[key]) or rawget(tVar,tVar.mapping[key])
	else
		return rawget(tVar,key)
	end
end
mt.__newindex = function (table, key, value)
	if tVar.mapping[key] then
		rawset(table,tVar.mapping[key],value)
	else
		rawset(table,key,value)
	end
end

--- maps parameters to string command
--
tVar.mapping = {
	["NUMBERFORMAT"] = "numFormat",
	["MATH_ENVIRONMENT"] = "mathEnviroment",
	["OUTPUT_MODE"] = "outputMode",
	["EQUATION_NUMBERING"] = "numeration",
	["DECIMAL_SEPARATOR"] = "decimalSeparator",
	["MATRIX_COMMAND"] = "MATtexStyle",
	["MATRIX_EQUATION_AS_MATRIX"] = "eqTexAsMatrix",
	["VECTOR_COMMAND"] = "VECtexStyle",
	["OUTPUT_DISABLED"] = "disableOutput",
	["OUTPUT_COLORED"] = "coloredOuput",
	["UNIT_COMMAND"] = "unitCommand",
	["UNIT_N_IN_BASE_UNITS"] = "N_outputInBaseUnits",
	["UNIT_N_WITH_UNITS"] = "N_outputWithUnits",
	["UNIT_SHOW_IN_MATRIX"] = "MatrixShowUnits",
	["REMOVE_ZEROS"] = "autocutZero",
	["REMOVE_DECIMAL_SEPARATOR"] = "autocutDecimalSep",
	["CALC_PRECISION"] = "calcPrecision",
	["DEBUG_MODE"] = "debugMode",
	["DEBUG_LOG_COMMANDS_TO_FILE"] = "logInterp",
	["GNUPLOT_LIBRARY"] = "gnuplot_library",
	["GNUPLOT_TERMINAL"] = "gnuplot_terminal",
	["GNUPLOT_FILE_NAME_EXTENSION"] = "gnuplot_file_extensions",
}


setmetatable(tVar, mt)

--- create new tVar object. tVar has all properties, functions and
-- metatables
-- 
-- @param _val (number) value of LaTeX Variable
-- @param _nameTex (string) LaTeX representation
-- @return (tVar) Number with LaTeX representation
function tVar:New(_val,_nameTex)
	if ismetatable(_val,tVar) then return _val end
	local ret = {}
	setmetatable(ret,self)
	self.__index = function(table, key)
		if tVar.mapping[key] then
			return rawget(table,tVar.mapping[key]) or rawget(tVar,tVar.mapping[key])
		else
			return rawget(tVar,key)
		end
	end
	self.__newindex = function (table, key, value)
		if tVar.mapping[key] then
			rawset(table,tVar.mapping[key],value)
		else
			rawset(table,key,value)
		end
	end
	self.__add = self.Add
	self.__sub = self.Sub
	self.__mul = self.Mul
	self.__div = self.Div
	self.__pow = self.Pow
	self.__unm = self.Neg
	self.__call = self.intCall
	--self.__tostring = self.print
	self.__eq = self.Equal
	self.__lt = self.LowerT
	self.__le = self.LowerTE
	self.__concat = self.concatnameTex
	ret.val = _val


	if _nameTex ~= nil then
		ret.nameTex = _nameTex
		ret.eqTex = _nameTex
	else
		ret.nameTex = tVar.formatValue(tVar.numFormat,_val,tVar.decimalSeparator)
		ret.eqTex = ret.nameTex
	end

	ret.eqNum = ret:pFormatVal()
	return ret
end
