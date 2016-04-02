local units = tVar.units

do -- length, area, volumen and pow4
	units("m")
	units():mul(1e-3,units("m")):addUnit("mm")
	units():mul(0.1,units("m")):addUnit("dm")
	units():mul(1e-2,units("m")):addUnit("cm")
	units():mul(1000,units("m")):addUnit("km")

	units("m"):mul(1,units("m")):addUnit("m^2")
	units("mm"):mul(1,units("mm")):addUnit("mm^2")
	units("cm"):mul(1,units("cm")):addUnit("cm^2")
	units("dm"):mul(1,units("dm")):addUnit("dm^2")
	units("km"):mul(1,units("km")):addUnit("km^2")

	units("m"):mul(1,units("m")):mul(1,units("m")):addUnit("m^3")
	units("mm"):mul(1,units("mm")):mul(1,units("mm")):addUnit("mm^3")
	units("cm"):mul(1,units("cm")):mul(1,units("cm")):addUnit("cm^3")
	units("dm"):mul(1,units("dm")):mul(1,units("dm")):addUnit("dm^3")
	units("km"):mul(1,units("km")):mul(1,units("km")):addUnit("km^3")

	units("m"):mul(1,units("m")):mul(1,units("m")):mul(1,units("m")):addUnit("m^4")
	units("mm"):mul(1,units("mm")):mul(1,units("mm")):mul(1,units("mm")):addUnit("mm^4")
	units("cm"):mul(1,units("cm")):mul(1,units("cm")):mul(1,units("cm")):addUnit("cm^4")
	units("dm"):mul(1,units("dm")):mul(1,units("dm")):mul(1,units("dm")):addUnit("dm^4")
	units("km"):mul(1,units("km")):mul(1,units("km")):mul(1,units("km")):addUnit("km^4")
end
do -- weight
	units("kg")
	units():mul(1e-3,units("kg")):addUnit("g")
	units():mul(1e3,units("kg")):addUnit("t")
end
do -- time
	units("s")
	units("s"):mul(1,units("s")):addUnit("s^2")
	units():mul(1e-3,units("s")):addUnit("ms")
	units():mul(60,units("s")):addUnit("min")
	units():mul(60,units("min")):addUnit("h")
	units():mul(24,units("h")):addUnit("day")
	units():mul(7,units("d")):addUnit("week")
end
do -- force
	units():mul(1,units("kg")):mul(1,units("m")):div(1,units("s^2")):addUnit("N")
	units():mul(1000,units("N")):addUnit("kN")
	units():mul(1e6,units("N")):addUnit("MN")
	units():mul(1e9,units("N")):addUnit("GN")
end
do -- pressure
	units():mul(1,units("N")):div(1,units("m^2")):addUnit("Pa")
	units():mul(1e6,units("Pa")):addUnit("MPa")
	units():mul(1e9,units("Pa")):addUnit("GPa")
end
do -- temperature
	units("K")
	units("°C")
end
do -- angles
	units(""):mul(1):addUnit("rad")
	units("rad"):div(180):mul(3.14159265358979323846264338327950):addUnit("°")
end
do -- power
	units():mul(1,units("kg")):mul(1,units("m^2")):div(1,units("s^3")):addUnit("W")
	units("W"):mul(1,units("s")):addUnit("J")
end
do -- frequency
	units():div(1,units("s")):addUnit("Hz")
	units():div(1,units("Hz")):div(1,units("Hz")):addUnit("Hz^2")
end
do -- percent
	units():div(100):addUnit("\\%")
end