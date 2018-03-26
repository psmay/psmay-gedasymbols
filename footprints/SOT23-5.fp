# description: SOT23-5
# author: Peter S. May
# email: gedasymbols@psmay.com
# dist-license: unlimited
# use-license: unlimited

# Based on generated SOT23-6 footprint by deleting pad 5 and then renaming/reconnecting pad 6 as pad 5.
# At some point this should be automated. Until then, repeat this process anytime SOT23-6 changes.
Element["" "SOT23-5" "U?" "SOT23-5" 0 0 0 0 0 100 ""]
(
	Attribute("gedasymbols::url" "https://github.com/psmay/psmay-gedasymbols/raw/master/footprints/SOT23-5.fp")
	Pad[-5216 -3740 -4232 -3740 2165 2000 4165 "1" "1" "square"]
	Pad[-5216 0 -4232 0 2165 2000 4165 "2" "2" "square"]
	Pad[-5216 3740 -4232 3740 2165 2000 4165 "3" "3" "square"]
	Pad[5216 3740 4232 3740 2165 2000 4165 "4" "4" "square"]
	Pad[5216 -3740 4232 -3740 2165 2000 4165 "5" "5" "square"]
	ElementArc[0 -6322 1049 1049 0 180 1000]
	ElementLine[-2952 -6322 -1049 -6322 1000]
	ElementLine[1049 -6322 2952 -6322 1000]
	ElementLine[-2952 6322 2952 6322 1000]
	ElementLine[1649 -6322 1649 6322 1000]
	ElementLine[-1649 6322 -1649 -6322 1000]
)
