# DESCRIPTION
TexVar (short tVar) is a basic LaTeX math calculations tool written in Lua. For integration into LaTeX, it has to be used together with LuaLaTeX. Compared to software like Mathcad TexVar is a lot more flexible. You can fill custom designed tables with results, do calculations within text documents and print beautiful LaTeX equations. The current version also supports 2D-plotting with gnuplot.

Currently the following operations are supported:
- Basic math operators
- Lua math library
- Matrix and Vector calculations
- 2D Plots with Gnuplot

Project Website [texvar.projectzoo.at](http://texvar.projectzoo.at)

# DEPENDENCIES
- LuaTeX
- Lua Modules
	- luamatrix
- GnuPlot 5.0 (change path to gnuplot executable in .config file and run lualatex with --shell-escape)
- Latex Modules
	- luacode
	- amsmath
	- graphicsx (plotting)
	- color (debuging)

# INSTALLATION
Just download the folders and copy lib and tVar into the folder your *.tex script is.

# GETTING STARTED
The best way to start with TexVar is reading the manual.

# LICENSE
TexVar is a free software distributed under the terms of the MIT license.

# DEVELOPER
Sebastian Pech
