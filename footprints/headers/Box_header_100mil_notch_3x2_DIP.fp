# dimensions-based-on = Sullins SBH11-PBPC-Dxx-ST-xx
# numbering = DIP

Element["" "Header, 3x2, 100mil pitch, shrouded, notched, DIP pin numbering" "CONN?" "Box_header_100mil_notch_3x2_DIP" 7.6835mm 4.527mm -6.1595mm 2.742mm 1 100 ""]
(
	Attribute("author" "Peter S. May")
	Attribute("email" "gedasymbols@psmay.com")
	Attribute("dist-license" "unlimited")
	Attribute("use-license" "unlimited")
	Attribute("gedasymbols::url" "https://github.com/psmay/psmay-gedasymbols/raw/master/footprints/headers/Box_header_100mil_notch_3x2_DIP.fp")

	Pin[-2.54mm 1.27mm 1.524mm 0.762mm 1.6764mm 0.9652mm "" "1" "edge2,square"]
	Pin[-2.54mm -1.27mm 1.524mm 0.762mm 1.6764mm 0.9652mm "" "6" "edge2"]
	Pin[0mm 1.27mm 1.524mm 0.762mm 1.6764mm 0.9652mm "" "2" "edge2"]
	Pin[0mm -1.27mm 1.524mm 0.762mm 1.6764mm 0.9652mm "" "5" "edge2"]
	Pin[2.54mm 1.27mm 1.524mm 0.762mm 1.6764mm 0.9652mm "" "3" "edge2"]
	Pin[2.54mm -1.27mm 1.524mm 0.762mm 1.6764mm 0.9652mm "" "4" "edge2"]

	ElementLine [-7.5565mm -4.4mm 7.5565mm -4.4mm 0.254mm]
	ElementLine [7.5565mm -4.4mm 7.5565mm 4.4mm 0.254mm]
	ElementLine [7.5565mm 4.4mm -7.5565mm 4.4mm 0.254mm]
	ElementLine [-7.5565mm 4.4mm -7.5565mm -4.4mm 0.254mm]

	ElementLine [-2.25mm 4.4mm -2.25mm 2.55mm 0.254mm]
	ElementLine [-2.25mm 2.55mm 2.25mm 2.55mm 0.254mm]
	ElementLine [2.25mm 2.55mm 2.25mm 4.4mm 0.254mm]

	ElementLine [-2.25mm 3.75mm -6.9135mm 3.75mm 0.254mm]
	ElementLine [-6.9135mm 3.75mm -6.9135mm -3.75mm 0.254mm]
	ElementLine [-6.9135mm -3.75mm 6.9135mm -3.75mm 0.254mm]
	ElementLine [6.9135mm -3.75mm 6.9135mm 3.75mm 0.254mm]
	ElementLine [6.9135mm 3.75mm 2.25mm 3.75mm 0.254mm]

	ElementLine [-2.25mm 3.25mm -6.4135mm 3.25mm 0.254mm]
	ElementLine [-6.4135mm 3.25mm -6.4135mm -3.25mm 0.254mm]
	ElementLine [-6.4135mm -3.25mm 6.4135mm -3.25mm 0.254mm]
	ElementLine [6.4135mm -3.25mm 6.4135mm 3.25mm 0.254mm]
	ElementLine [6.4135mm 3.25mm 2.25mm 3.25mm 0.254mm]

	ElementLine [-6.9135mm -3.75mm -6.4135mm -3.25mm 0.254mm]
	ElementLine [6.9135mm -3.75mm 6.4135mm -3.25mm 0.254mm]
	ElementLine [6.9135mm 3.75mm 6.4135mm 3.25mm 0.254mm]
	ElementLine [-6.9135mm 3.75mm -6.4135mm 3.25mm 0.254mm]
)
