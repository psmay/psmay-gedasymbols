
# MO150AE: SSOP20 with 5.3mm body width (JEDEC M0-150-AE)
# Dimensions derived from National Semiconductor drawing (SC)MKT-MSA20 rev C

# Based on output from the footprint generator
# (http://www.gedasymbols.org/user/dj_delorie/tools/dilpad.html)
# but slightly tweaked. Parameters used:
# units: MM
# BL = 7.2
# BW = 5.3
# CW = 7.8
# E = .65
# PL = 2.25
# PLC = 6.55
# PW = 0.43
# SO = 0.2
# SW = 0.6

Element["" "MO150AE" "U?" "val" 17325 15535 -2000 -8000 0 100 ""]
(
	Pad[-16476 -11515 -9311 -11515 1692 0 1692 "1" "1" ""]
	Pad[-16476 -8956 -9311 -8956 1692 0 1692 "2" "2" "square"]
	Pad[-16476 -6397 -9311 -6397 1692 0 1692 "3" "3" "square"]
	Pad[-16476 -3838 -9311 -3838 1692 0 1692 "4" "4" "square"]
	Pad[-16476 -1279 -9311 -1279 1692 0 1692 "5" "5" "square"]
	Pad[-16476 1279 -9311 1279 1692 0 1692 "6" "6" "square"]
	Pad[-16476 3838 -9311 3838 1692 0 1692 "7" "7" "square"]
	Pad[-16476 6397 -9311 6397 1692 0 1692 "8" "8" "square"]
	Pad[-16476 8956 -9311 8956 1692 0 1692 "9" "9" "square"]
	Pad[-16476 11515 -9311 11515 1692 0 1692 "10" "10" "square"]
	Pad[9311 11515 16476 11515 1692 0 1692 "11" "11" "square,edge2"]
	Pad[9311 8956 16476 8956 1692 0 1692 "12" "12" "square,edge2"]
	Pad[9311 6397 16476 6397 1692 0 1692 "13" "13" "square,edge2"]
	Pad[9311 3838 16476 3838 1692 0 1692 "14" "14" "square,edge2"]
	Pad[9311 1279 16476 1279 1692 0 1692 "15" "15" "square,edge2"]
	Pad[9311 -1279 16476 -1279 1692 0 1692 "16" "16" "square,edge2"]
	Pad[9311 -3838 16476 -3838 1692 0 1692 "17" "17" "square,edge2"]
	Pad[9311 -6397 16476 -6397 1692 0 1692 "18" "18" "square,edge2"]
	Pad[9311 -8956 16476 -8956 1692 0 1692 "19" "19" "square,edge2"]
	Pad[9311 -11515 16476 -11515 1692 0 1692 "20" "20" "square,edge2"]
	ElementLine [-10433 -14330 -2821 -14330 2362]
	ElementLine [2821 -14330 10433 -14330 2362]
	ElementLine [-10433 14330 10433 14330 2362]
	ElementLine [6496 -14330 6496 14330 2362]
	ElementLine [-6496 14330 -6496 -14330 2362]
	ElementArc [0 -14330 2821 2821 0 180 2362]

	)