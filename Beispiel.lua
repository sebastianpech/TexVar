dofile"D:\\Meine Dateien\\Projekte\\201505_LuaLatexCAS\\tVar.lua"

-- Berechne den U-Wert einer Schicht
d = tVar:New(10,"d_{1}")
lambda = tVar:New(0.035,"\\lambda_{1}")
R = d/lambda

U=R:bracR()^(-1)
U.nameTex = "U"
print(U:printFull())