# How to write custom functions for tVar
tVar.outputMode = "RES_EQ"
tVar.decimalSeparator = ","
tVar.qOutput = true
tMat.eqTexAsMatrix = false

# Calculating the angle between two vectors
a:={3,0,0}
b:={4,4,0}

a_n=(a/tVar.sqrt(a*a)):setName("a_n"):print():clean()
b_n=(b/tVar.sqrt(b*b)):setName("b_n"):print():clean()
alpha = (tVar.deg(tVar.acos(a_n*b_n))):setName("\\alpha"):print():clean()
# 
# Calculating the angle between two vectors with custom functions\\\\
require("custom.lua")
a_n=tVec.norm(a):setName("a_n"):print():clean()
b_n=tVec.norm(b):setName("b_n"):print():clean()
alpha = (tVar.deg(tVar.acos(a_n*b_n))):setName("\\alpha"):print():clean()