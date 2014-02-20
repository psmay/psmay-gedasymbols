
# Murata_CERALOCK_Resonator_CSTCE_V: Footprint V from CSTCE resonator series
# Dimensions are as given in
# "Ceramic Resonator (CERALOCK®) Application Manual", cat no. P17E-18

# Based on output from the footprint generator
# (http://www.gedasymbols.org/user/dj_delorie/tools/2pad.html)
# but modified to add a third pin and slightly tweaked. Parameters used:
# units: MM
# PLC = 1.9
# PT = 0.3
# PW = 1.6
# SO = 0.2
# SW = 0.2
Element["" "Murata_CERALOCK_Resonator_CSTCE_V" "" "" 0 0 0 0 0 100 ""]
(
	Pad[-3740 2559 -3740 -2559 1181 0 1181 "1" "1" "square"]
	Pad[0 2559 0 -2559 1181 0 1181 "2" "2" "square"]
	Pad[3740 2559 3740 -2559 1181 0 1181 "3" "3" "square"]
	ElementLine[-4330 -4329 5510 -4329 787]
	ElementLine[-4330 4329 5510 4329 787]
	ElementLine[5510 -4329 5510 4329 787]
	ElementLine[-5510 -3149 -5510 3149 787]
	ElementArc[-4330 -3149 1180 1180 0 -90 787]
	ElementArc[-4330 3149 1180 1180 0 90 787]
)
