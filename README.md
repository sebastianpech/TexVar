# Description
TexVar (short tVar) is a basic LaTeX math calculations tool written in Lua. For
integration into LaTeX, it has to be used together with LuaLaTeX. Compared to
software like Mathcad TexVar is a lot more flexible. You can fill custom
designed tables with results, do calculations within text documents and print
beautiful LaTeX equations. The current version also supports 2D-plotting with
gnuplot.

Currently the following operations are supported:

* Basic math operators
* Lua math library
* Matrix and Vector calculations
* 2D Plots with Gnuplot

Upcoming features/task:

* Calculations with units
* Launch project on CTAN

For a better understanding on what TexVar does you should have a look at this
[presentation on SlideShare](http://de.slideshare.net/Specht08/texvar-mathematical-calculations-in-latex-made-easy).

# Download
The download contains the LuaLaTeX-Package and the TexVar-Library,

[TexVar 1.5.22](https://github.com/sebastianpech/TexVar/archive/1.5.22.zip)
[TexVar 1.5.23](https://github.com/sebastianpech/TexVar/archive/1.5.23.zip)

# Dependencies
* Lua 5.1-5.3
* LuaLaTeX (contained in MiKTex, TeX Live and MacTeX)
* GnuPlot 5.0 (only for plotting) 
* Latex Modules
    * luacode
    * amsmath
    * siunitx
    * graphicsx (plotting)
    * color (debuging)

# License
TexVar is a free software distributed under the terms of the MIT license.

# Getting Started

## Manual
The best way to start with TexVar is by reading the manual.

[TexVar Manual](https://github.com/sebastianpech/TexVar-Manual/raw/master/TexVar_Manual.pdf)

## Installation
There is no installation needed. The folders tVar and lib only need to be in
the same folder your executable file is. For plotting you need to change the
path to your gnuplot install with the command: 

```latex
% Linux and Mac
tPlot.gnuplot_library = "gnuplot"
% Windows
tPlot.gnuplot_library = [==["WINDOWSPATH"]==]
```

## Need more Help?
In case you need further information or help on using TexVar, just send 
[me an email](mailto:sebastian.pech@me.com).

# Tips

## How to disable TexVar calculations
When working together with others on one LaTeX document, using TexVar can cause
problems, when only one person has a working version. To temporarily disable
TexVar execution you can easily redefine the tVar environment. The following
code requires the listings package.

```latex
% Instead of
% \usepackage{texvar}
% write
\lstnewenvironment{tVar}{}{}
```

The advantage of converting the tVar environment into a listings environment
is, that the code is still visible but not executed.
