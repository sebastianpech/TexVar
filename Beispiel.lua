require("tVar")
matrix = require("matrix")
tVar.numFormat = "%.3f"
v_1=tVar:New(20,"v_{1}")
v_2=tVar:New(20,"v_{2}")
v_3 = ((v_1+v_2):bracR()*v_2):setName("v_{3}")
print(v_1==v_2)
