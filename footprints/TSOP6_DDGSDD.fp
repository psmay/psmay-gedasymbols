
# Dimensions (except for M) derived from data for PMN27XPE
# http://www.nxp.com/documents/data_sheet/PMN27XPE.pdf

# units: MM
# BL = 2.9
# BW = 1.5
# C = 0.1
# CW = 2.75
# E = 0.95
# LW = 0.325
# M = 0.1
# PL = 0.8
# PLC = 2.4
# PW = 0.55
# SO = 0.2
# SW = 0.2
Element["" "TSOP6_DDGSDD" "" "" 6697 6404 2596 -2303 0 100 ""]
(
	Pad[-5216 -3740 -4232 -3740 2165 787 2952 "" "D" "square"]
	Pad[-5216 0 -4232 0 2165 787 2952 "" "D" "square"]
	Pad[-5216 3740 -4232 3740 2165 787 2952 "" "G" "square"]
	Pad[4232 3740 5216 3740 2165 787 2952 "" "S" "square,edge2"]
	Pad[4232 0 5216 0 2165 787 2952 "" "D" "square,edge2"]
	Pad[4232 -3740 5216 -3740 2165 787 2952 "" "D" "square,edge2"]
	ElementLine [-2952 -6003 -1049 -6003 787]
	ElementLine [1049 -6003 2952 -6003 787]
	ElementLine [-2952 6003 2952 6003 787]
	ElementLine [1968 -6003 1968 6003 787]
	ElementLine [-1968 6003 -1968 -6003 787]
	ElementArc [0 -6003 1049 1049 0 180 787]
	)
