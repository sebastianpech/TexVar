-- Unit definitions

tUnit = {}

function tUnit.rootpow(a,b)
	if not a then return nil end
	return a:copy():root(b)
end
