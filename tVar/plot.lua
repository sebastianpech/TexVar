----------------------------------------------------------------------------
-- Plot functionality
-- contains all the functions and tables for plotting
--
----------------------------------------------------------------------------

tPlot = {
	--gnuplot_library=[[""D:\Meine Dateien/Software_Programme/gnuplot/bin/gnuplot.exe"]]
	gnuplot_library="gnuplot",
	terminal = "eps",
	conf = {},
}
--- Initialize tPlot table
--
-- @param steps (number) Resolution, steps between xmin and xmax
-- @param stack counts and holds the created plots (globally)
tPlot.steps = 0.1
tPlot.stack = {}
tPlot.stack.add = function(elem)
	tPlot.stack[#tPlot.stack+1] = elem
	return #tPlot.stack - 1
end
--- Create New PLot
--
-- @param present (optional) you can pass a previously created plot as template. Set values are overrideable
-- @return new Plot
function tPlot:New(present)
	local ret = {}

	ret.commands = {
		
	}
	ret.fn = {}
	ret.conf = {}
	ret.conf.xrange = {}

	ret.conf.xrange.min = 0
	ret.conf.xrange.max = 10

	ret.conf.present = present

	ret.size = "14cm,8cm"

	self.__index = self
	self.__newindex = self.forwardCommand

	setmetatable(ret,self)
	return ret
end
--- Add function or datapoints {{X1.,Y1}{X2,Y2}} to plot
--
-- @param fun functiontion or datapoints
-- @param title title of the plot
-- @param style 
function tPlot:add(fun,title,style)
	self.fn[#self.fn+1] = {fun,title,style}
end
--- Pushes a command to the plot command stack
--
-- @param command as string
function tPlot:push(command)
	self.commands[#self.commands+1]=command
end
--- Plots the tPot object
-- 
function tPlot:plot()
	-- check if Plot has any functions	
	if #self.fn == 0 then error("No functions to plot!") end

	-- connect to gnuplot executeable
	local execState = self.gnuplot_library
	local gnuplotTerminal = io.popen(execState,"w")

	-- create filename
	local temp = "tmp_"..tPlot.stack.add(self) .. "." .. self.FileExtension

	-- set terminal and outputpath
	gnuplotTerminal:write("set terminal "..self.terminal .. " size " .. self.size .. "\n")
	gnuplotTerminal:write("set output '" .. temp .. "'\n")

	-- check for present tPlot objects and load the commands
	if self.conf.presen then
		for i,v in ipairs(self.present.commands) do
			gnuplotTerminal:write(v .. "\n")
		end
	end

	-- write own commands to gnuplot terminal
	for i,v in ipairs(self.commands) do
		gnuplotTerminal:write(v .. "\n")
	end

	-- start plotting
	gnuplotTerminal:write("plot")

	-- register functions
	for i,v in ipairs(self.fn) do
		if i == #self.fn then
			gnuplotTerminal:write(" '-' " .. v[3] .. " title '" .. v[2] .. "'")
		else
			gnuplotTerminal:write(" '-' " .. v[3] .. " title '" .. v[2] .. "',")
		end
	end

	-- write datapoints or functions
	for i,v in ipairs(self.fn) do
		if type(v[1]) == "function" then
			for j=self.conf.xrange.min,self.conf.xrange.max,self.steps do
				local funValue = v[1](tVar.roundNumToPrec(j))  
				if tonumber(funValue) then
					gnuplotTerminal:write("\n" .. j .. " " .. tVar.Check(funValue).val )
				end
			end
		elseif type(v[1]) == "table" then
			for j,w in ipairs(v[1]) do
				gnuplotTerminal:write("\n" .. tVar.Check(w[1]).val .. " " .. tVar.Check(w[2]).val )
			end
		end
		-- end input
		gnuplotTerminal:write("\ne")
	end

	gnuplotTerminal:close()
	-- print latex 
	tPlot.imgFormat(temp)
end
--- print path with latex image include
--
-- @param path
function tPlot.imgFormat(path)
  		tex.print("\\includegraphics{" .. path .. "}")
end
--- translate every acces to undefined object to set method
--
-- @param table self
-- @param key in table
-- @param value
function tPlot.forwardCommand(table,key,value)
	if key == "xrange" then
		local slt = string.split(value,":")
		table.conf.xrange.min = string.sub(slt[1],2)
		table.conf.xrange.max = string.sub(slt[2],1,-2)
	end
	if tonumber(value) or (string.sub(value,1,1) == "[" and string.sub(value,-1,-1) == "]") then
		table:push("set " .. key .. " " .. value .. "")
	else
		table:push("set " .. key .. " '" .. value .. "'")
	end
end