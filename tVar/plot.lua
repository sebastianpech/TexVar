tPlot = {
	--gnuplot_library=[[""D:\Meine Dateien/Software_Programme/gnuplot/bin/gnuplot.exe"]]
	gnuplot_library="gnuplot",
	terminal = "eps"
}

tPlot.stack = {}
tPlot.stack.add = function(elem)
	tPlot.stack[#tPlot.stack+1] = elem
	return #tPlot.stack - 1
end

function tPlot:New(present)
	local ret = {}

	ret.commands = {
		
	}
	ret.fn = {}
	ret.conf = {}
	ret.conf.xrange = {}

	ret.conf.xrange.min = 0
	ret.conf.xrange.max = 10
	ret.conf.steps = 0.1

	ret.conf.present = present

	self.__index = self
	self.__newindex = self.forwardCommand

	setmetatable(ret,self)
	return ret
end

function tPlot:add(fun,title,style)
	self.fn[#self.fn+1] = {fun,title,style}
end

function tPlot:push(command)
	self.commands[#self.commands+1]=command
end

function tPlot:plot()
	--generate plot data X Y
	
	if #self.fn == 0 then error("No functions to plot!") end

	local execState = self.gnuplot_library
	local gnuplotTerminal = io.popen(execState,"w")

	local temp = "tmp_"..tPlot.stack.add(self) .. "." .. self.terminal

	gnuplotTerminal:write("set terminal "..self.terminal .. "\n")
	gnuplotTerminal:write("set output '" .. temp .. "'\n")

	-- check for present commands
	if self.conf.presen then
		for i,v in ipairs(self.present.commands) do
			gnuplotTerminal:write(v .. "\n")
		end
	end

	for i,v in ipairs(self.commands) do
		gnuplotTerminal:write(v .. "\n")
	end

	gnuplotTerminal:write("plot")

	for i,v in ipairs(self.fn) do
		if i == #self.fn then
			gnuplotTerminal:write(" '-' " .. v[3] .. " title '" .. v[2] .. "'")
		else
			gnuplotTerminal:write(" '-' " .. v[3] .. " title '" .. v[2] .. "',")
		end
	end

	for i,v in ipairs(self.fn) do
		for j=self.conf.xrange.min,self.conf.xrange.max,self.conf.steps do
			gnuplotTerminal:write("\n" .. j .. " " .. tVar.Check(v[1](j)).val )
		end
		gnuplotTerminal:write("\ne")
	end

	gnuplotTerminal:close()
	tPlot.imgFormat(temp)
end

function tPlot.imgFormat(path)
		tex.print("\\begin{figure}[ht]")
		tex.print("\\centering")
  		tex.print("\\includegraphics{" .. path .. "}")
		tex.print("\\end{figure}")
end

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