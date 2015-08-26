tex = {}
dofile("D:/Meine Dateien/Git/TexVar/tVar.lua")
tVar.decimalSeparator = ","
matrix = require("matrix")
b = tVar:New(3,"a")
print(b:printFull())

a = 5-b
print(b:printFull())
