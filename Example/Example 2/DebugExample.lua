--- Code for debugging purposes
--
-- redefine tex and print function for console output
tex={}
tex.print = print

-- load tVar module
require("tVar")

--- do test calculations
A= tMat:New({{1,2,3},{3,4,5},{6,7,8}},"A")
B= tMat:New({{3,1,4},{5,3,1},{4,3,1}},"B")

C=(A*B):setName("C"):print():clean()
