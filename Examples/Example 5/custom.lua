function tVec.normNumber(a)
	local sum = 0
	for i=1,#a do
		sum = sum + a[i][1]^2
	end
	for i=1,#a do
		a[i][1] = a[i][1]/math.sqrt(sum)
	end
	return a
end

tVec.norm = tVar.link(tVec.normNumber,"|","|",tVec)