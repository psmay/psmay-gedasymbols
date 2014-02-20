
# MO150AH: SSOP20 with 5.3mm body width (JEDEC M0-150-AH)
# Pad width reduced to below-standard 0.38mm to allow for smearing in hobbyist fabrication
# Other dimensions derived from National Semiconductor drawing (SC)MKT-MSA20 rev C
# (Extended to 28 pins)

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
# PW = 0.38
# SO = 0.2
# SW = 0.6

Element["" "MO150AH_with_0.38mm_thin_pads" "U?" "val" 17325 15535 -2000 -8000 0 100 ""]
(
	Pad[-16574 -16633 -9212 -16633 1496 0 1496 "1" "1" ""]
	Pad[-16574 -14074 -9212 -14074 1496 0 1496 "2" "2" "square"]
	Pad[-16574 -11515 -9212 -11515 1496 0 1496 "3" "3" "square"]
	Pad[-16574 -8956 -9212 -8956 1496 0 1496 "4" "4" "square"]
	Pad[-16574 -6397 -9212 -6397 1496 0 1496 "5" "5" "square"]
	Pad[-16574 -3838 -9212 -3838 1496 0 1496 "6" "6" "square"]
	Pad[-16574 -1279 -9212 -1279 1496 0 1496 "7" "7" "square"]
	Pad[-16574 1279 -9212 1279 1496 0 1496 "8" "8" "square"]
	Pad[-16574 3838 -9212 3838 1496 0 1496 "9" "9" "square"]
	Pad[-16574 6397 -9212 6397 1496 0 1496 "10" "10" "square"]
	Pad[-16574 8956 -9212 8956 1496 0 1496 "11" "11" "square"]
	Pad[-16574 11515 -9212 11515 1496 0 1496 "12" "12" "square"]
	Pad[-16574 14074 -9212 14074 1496 0 1496 "13" "13" "square"]
	Pad[-16574 16633 -9212 16633 1496 0 1496 "14" "14" "square"]
	Pad[9212 16633 16574 16633 1496 0 1496 "15" "15" "square,edge2"]
	Pad[9212 14074 16574 14074 1496 0 1496 "16" "16" "square,edge2"]
	Pad[9212 11515 16574 11515 1496 0 1496 "17" "17" "square,edge2"]
	Pad[9212 8956 16574 8956 1496 0 1496 "18" "18" "square,edge2"]
	Pad[9212 6397 16574 6397 1496 0 1496 "19" "19" "square,edge2"]
	Pad[9212 3838 16574 3838 1496 0 1496 "20" "20" "square,edge2"]
	Pad[9212 1279 16574 1279 1496 0 1496 "21" "21" "square,edge2"]
	Pad[9212 -1279 16574 -1279 1496 0 1496 "22" "22" "square,edge2"]
	Pad[9212 -3838 16574 -3838 1496 0 1496 "23" "23" "square,edge2"]
	Pad[9212 -6397 16574 -6397 1496 0 1496 "24" "24" "square,edge2"]
	Pad[9212 -8956 16574 -8956 1496 0 1496 "25" "25" "square,edge2"]
	Pad[9212 -11515 16574 -11515 1496 0 1496 "26" "26" "square,edge2"]
	Pad[9212 -14074 16574 -14074 1496 0 1496 "27" "27" "square,edge2"]
	Pad[9212 -16633 16574 -16633 1496 0 1496 "28" "28" "square,edge2"]
	ElementLine [-10433 -19349 -2821 -19349 2362]
	ElementLine [2821 -19349 10433 -19349 2362]
	ElementLine [-10433 19349 10433 19349 2362]
	ElementLine [6496 -19349 6496 19349 2362]
	ElementLine [-6496 19349 -6496 -19349 2362]
	ElementArc [0 -19349 2821 2821 0 180 2362]

	)
