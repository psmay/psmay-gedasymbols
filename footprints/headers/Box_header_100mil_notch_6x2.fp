# dimensions-based-on = Sullins SBH11-PBPC-Dxx-ST-xx
# numbering = ribbon

Element["" "Header, 6x2, 100mil pitch, shrouded, notched, ribbon cable numbering" "CONN?" "Box_header_100mil_notch_6x2" 11.4935mm 4.527mm -9.9695mm 2.742mm 1 100 ""]
(
	Attribute("author" "Peter S. May")
	Attribute("email" "gedasymbols@psmay.com")
	Attribute("dist-license" "unlimited")
	Attribute("use-license" "unlimited")
	Attribute("gedasymbols::url" "https://github.com/psmay/psmay-gedasymbols/raw/master/footprints/headers/Box_header_100mil_notch_6x2.fp")

	Pin[-6.35mm 1.27mm 1.524mm 0.762mm 1.6764mm 0.9652mm "" "1" "edge2,square"]
	Pin[-6.35mm -1.27mm 1.524mm 0.762mm 1.6764mm 0.9652mm "" "2" "edge2"]
	Pin[-3.81mm 1.27mm 1.524mm 0.762mm 1.6764mm 0.9652mm "" "3" "edge2"]
	Pin[-3.81mm -1.27mm 1.524mm 0.762mm 1.6764mm 0.9652mm "" "4" "edge2"]
	Pin[-1.27mm 1.27mm 1.524mm 0.762mm 1.6764mm 0.9652mm "" "5" "edge2"]
	Pin[-1.27mm -1.27mm 1.524mm 0.762mm 1.6764mm 0.9652mm "" "6" "edge2"]
	Pin[1.27mm 1.27mm 1.524mm 0.762mm 1.6764mm 0.9652mm "" "7" "edge2"]
	Pin[1.27mm -1.27mm 1.524mm 0.762mm 1.6764mm 0.9652mm "" "8" "edge2"]
	Pin[3.81mm 1.27mm 1.524mm 0.762mm 1.6764mm 0.9652mm "" "9" "edge2"]
	Pin[3.81mm -1.27mm 1.524mm 0.762mm 1.6764mm 0.9652mm "" "10" "edge2"]
	Pin[6.35mm 1.27mm 1.524mm 0.762mm 1.6764mm 0.9652mm "" "11" "edge2"]
	Pin[6.35mm -1.27mm 1.524mm 0.762mm 1.6764mm 0.9652mm "" "12" "edge2"]

	ElementLine [-11.3665mm -4.4mm 11.3665mm -4.4mm 0.254mm]
	ElementLine [11.3665mm -4.4mm 11.3665mm 4.4mm 0.254mm]
	ElementLine [11.3665mm 4.4mm -11.3665mm 4.4mm 0.254mm]
	ElementLine [-11.3665mm 4.4mm -11.3665mm -4.4mm 0.254mm]

	ElementLine [-2.25mm 4.4mm -2.25mm 2.55mm 0.254mm]
	ElementLine [-2.25mm 2.55mm 2.25mm 2.55mm 0.254mm]
	ElementLine [2.25mm 2.55mm 2.25mm 4.4mm 0.254mm]

	ElementLine [-2.25mm 3.75mm -10.7235mm 3.75mm 0.254mm]
	ElementLine [-10.7235mm 3.75mm -10.7235mm -3.75mm 0.254mm]
	ElementLine [-10.7235mm -3.75mm 10.7235mm -3.75mm 0.254mm]
	ElementLine [10.7235mm -3.75mm 10.7235mm 3.75mm 0.254mm]
	ElementLine [10.7235mm 3.75mm 2.25mm 3.75mm 0.254mm]

	ElementLine [-2.25mm 3.25mm -10.2235mm 3.25mm 0.254mm]
	ElementLine [-10.2235mm 3.25mm -10.2235mm -3.25mm 0.254mm]
	ElementLine [-10.2235mm -3.25mm 10.2235mm -3.25mm 0.254mm]
	ElementLine [10.2235mm -3.25mm 10.2235mm 3.25mm 0.254mm]
	ElementLine [10.2235mm 3.25mm 2.25mm 3.25mm 0.254mm]

	ElementLine [-10.7235mm -3.75mm -10.2235mm -3.25mm 0.254mm]
	ElementLine [10.7235mm -3.75mm 10.2235mm -3.25mm 0.254mm]
	ElementLine [10.7235mm 3.75mm 10.2235mm 3.25mm 0.254mm]
	ElementLine [-10.7235mm 3.75mm -10.2235mm 3.25mm 0.254mm]
)
