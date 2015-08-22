tex = {}
require("tVar")
matrix = require("matrix")
tVar.numFormat = "%.3f"
a = tVar:New(10,"a")
b = tVar:New(15,"b")
c = tVar:New(20,"c")
v_max = tVar.min(a,b,c):setName("v_{max}")
print(v_max:printFull())
