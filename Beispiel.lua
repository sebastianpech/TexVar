require("tVar")
matrix = require("matrix")
tVar.numFormat = "%.3f"
v_1=tVec:New({10,2,7},"v_{1}")
v_2=tVec:New({3,1,2},"v_{2}")
v_3 = (v_1+v_2):bracR()-v_2
v_3:setName("v_{3}")
--full Output here
print(v_3:printFull())
