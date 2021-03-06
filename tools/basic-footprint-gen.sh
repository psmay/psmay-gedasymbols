#!/bin/sh

# If GEDA::Machinery is not installed globally, ensure that it is accounted for
# in the PERL5LIB and PATH variables.
# Get it from https://github.com/psmay/GEDA-Machinery

# To run without the module installed, set $MACH in the following then run:
#	export MACH=/path/to/GEDA-Machinery
#	export PERL5LIB="$PERL5LIB:$MACH/lib"
#	export PATH="$PATH:$MACH/bin"

# The `aka` attributes added below, if any, are to be alphabetized.

# An entry in the `aka` attribute should be normalized such that all spaces and
# hyphens are removed except if between two digits (in which case the space
# would be replaced by a hyphen). This may make it easier to find a match.

#	TSOP-6          is spelled  TSOP6
#	SOT-23          is spelled  SOT23
#	SOT-23-5        is spelled  SOT23-5
#	SuperSOT-6      is spelled  SuperSOT6
#	Hyper Fake 12   is spelled  HyperFake12

# (That last one is made up.)

# The filenames should be arrived at similarly, but substitute underscores for
# any needed hyphens.

# The package name chosen for the footprint should simultaneously be common and
# thoroughly describe the footprint.
#
# If multiple options are equivalently common, prefer one that includes the
# number of pins directly, then one that relates it to a family of similar
# packages. For example, SC-74 and SOT457 are rather unhelpful names; the
# equivalent SOT23-6 and TSOP-6 both give a fairly clear idea that this is a
# footprint with 6 pins associated with a common suite of packages. Of the two,
# SOT23-6 seems to be more common.
#
# If the commonest thorough name is too vague or too obscure, use the common
# name suffixed with the first of this list that applies and thoroughly
# describes the footprint:
#	*   JEDEC designation
#	*   EIAJ designation
#	*   Designation used by vendor of common part using this footprint
#	*   As a last result, a plain description of the additional details
#
# For example, below is a footprint for SSOP-20 with a 5.3mm wide body. SSOP-20
# is the common name, but it is too vague—other widths, such as 4.4mm, are
# common (and possibly more common than 5.3mm). Still, the SSOP part is useful
# for associating it with some common values (such as pin-to-pin pitch) and the
# number of pins is included.
#
# The JEDEC name for this outline is MO-150-AE. This name very specifically
# describes the standard dimensions for this part. Technically, it even
# describes an association with a family, MO-150. However, it's a little
# cryptic, and you might have to have the spec in front of you to know that "AE"
# refers to the 20-pin variant, so I leave the SSOP-20 part on as a prefix.
#
# (Another designation for that footprint is—get this—SOT339-1. Avoid cryptic
# names like this as far as is possible.)

DEST=../footprints
URL_DEST="https://github.com/psmay/psmay-gedasymbols/raw/master/footprints"

AUTHOR="Peter S. May"
EMAIL="gedasymbols@psmay.com"
DIST_LICENSE=unlimited
USE_LICENSE=unlimited

#       dilpad  JEDEC   MCT     description
#       np      N       N       number of pads
#       bw      E1      E1      body width
#       bl      D       D       body length
#       cw      E       E       component width (lead tip to lead tip)
#       e       e       e, E*   lead pitch
#       pl      n/a     Y*, Y1* pad length (pad outer-to-inner)
#       plc     n/a     C*      pad length center-center (between centers of columns)
#       pw      n/a     X*, X1* pad width (pad length perpendicular to pl)
# * On recommended land pattern page of MCT packaging spec

# g: gap (inner-to-inner of opposite pads)
# pxl: pad extents length (outer-to-outer of opposite pads)
# (g and pxl can replace plc and pl)

# Mappings from JEDEC datum names to dilpad parameter names
J_N="np"	# number of pads
J_E1="bw"	# body width
J_D="bl"	# body length
J_E="cw"	# component width (between opposite lead tips)
J_e="e"		# lead pitch (center-center of adjacent leads)

# Mappings from Microchip land pattern names to dilpad parameter names
M_X="pw"	# pad width (edge to edge of single pad, perpendicular to pl)
M_X1="$M_X"
M_Y="pl"	# pad length (outer to inner of single pad)
M_Y1="$M_Y"
M_C="plc"	# pad column pitch (between opposite pad centers)

catdirs () {
	for fragment in "$@"; do
		path="$path/$fragment"
	done
	# The result of this ends with a trailing slash unless it refers to the
	# current directory.
	echo -n "$path" | perl -p -E '
		$_ = "./$_/";
		# Collapse "/./"
		while(s!/\./!/!g) {
			# keep going
		}
		# Collapse multiple slashes
		s!//+!/!g;
		# Remove artificial start
		s!^\./!!;
	'
}

dil () {
	dil_to "" "$@"
}

dil_to () {
	subdir="$1"
	shift
	id="$1"
	shift
	desc="$1"
	shift

	subdir="`catdirs "$subdir"`"
	mkdir -p "$DEST/$subdir"

	footprint-dilpad id="$id" description="$desc" \
		author="$AUTHOR" email="$EMAIL" dist-license="$DIST_LICENSE" use-license="$USE_LICENSE" \
		"@gedasymbols::url=$URL_DEST/$subdir$id.fp" \
		"$@" > "$DEST/$subdir$id.fp"
}

box_notch_header () {
	id="$1"
	shift
	desc="$1"
	shift
	columns="$1"
	shift
	rows="$1"
	shift

	subdir=headers
	mkdir -p "$DEST/$subdir"

	./box-header-with-notch.pl id="$id" description="$desc" \
		@author="$AUTHOR" @email="$EMAIL" \
		@dist-license="$DIST_LICENSE" @use-license="$USE_LICENSE" \
		"@gedasymbols::url=$URL_DEST/$subdir/$id.fp" \
		columns=$columns rows=$rows \
		"$@" > "$DEST/$subdir/$id.fp"
}

akas () {
	perl -E '$z{$_} = 1 for @ARGV; say "aka=" . join(", ", sort keys %z)' "$@"
}

# see the dilpad.pl perldoc for the meanings of these parameters

GEN="units=mm seq=A c=10mil m=10mil so=10mil sw=10mil"

# R-PDSO-G/SSOP-INCH Shrink Small Outline Package Family
# .025" (.635mm) Lead Pitch .150" (3.81mm) Wide Body

# bw (E1) = 154mil
#	(Wonder why the family desc says 150...)
# cw (E) = 236mil
# e (e) = 25mil
# Pad dimensions from land pattern in National MKT-MQA24 rev B
# g (pad cols gap inner-inner) = 123mil
# pxl (pad cols span outer-outer) = 296mil
# pw (pad width) = 157mil

draw_mo137a () {
	sub="$1"
	pins="$2"
	bl="$3"

	MO137_X="$GEN bw=154mil cw=236mil e=25mil g=123mil pxl=296mil"
	MO137="$MO137_X pw=15.7mil"

	#	AA	AB	AC	AD	AE	AF
	#	14	16	18	20	24	28	pins
	#	193	193	341	341	341 390	mil D (bl)

	Y="QSOP-$pins 0.15in-wide body (JEDEC MO-137-$sub)"
	Z="np=$pins bl=$bl"
	D='dimensions-based-on=JEDEC MO-137, National Semiconductor drawing MKT-MQA24 rev B'
	AKA="`akas QSOP$pins RPDSOG$pins DBQ$pins MQA$pins SSOPINCH$pins MO137$sub`"
	dil QSOP"$pins"_MO137"$sub" "$Y" "$D" "$AKA" $MO137 $Z
}

draw_mo137a AA 14 193mil
draw_mo137a AB 16 193mil
draw_mo137a AC 18 341mil
draw_mo137a AD 20 341mil
draw_mo137a AE 24 341mil
draw_mo137a AF 28 390mil

MO150_X="$GEN bw=5.3 cw=7.8 e=.65 pl=2.25 plc=6.55"
MO150="$MO150_X pw=0.43"
MO150_T="$MO150_X pw=0.38"

Y='SSOP-20 5.3mm-wide body (JEDEC MO-150-AE)'
Z='np=20 bl=7.2'
D='dimensions-based-on=National Semiconductor drawing (SC)MKT-MSA20 rev C'
AKA="`akas SSOP20 MO150AE SOT339 SOT339-1`"
dil SSOP20_MO150AE "$Y" "$D" "$AKA" $MO150 $Z
dil SSOP20_MO150AE_narrowed_pads "$Y, with narrowed 0.38mm pads" "$D" $MO150_T $Z

Y='SSOP-28 5.3mm-wide body (JEDEC MO-150-AH)'
Z='np=28 bl=10.2'
D='dimensions-based-on=National Semiconductor drawing (SC)MKT-MSA28 rev C'
AKA="`akas SSOP28 MO150AH SOT341 SOT341-1`"
dil SSOP28_MO150AH "$Y" "$D" "$AKA" $MO150 $Z
dil SSOP28_MO150AH_narrowed_pads "$Y, with narrowed 0.38mm pads" "$D" $MO150_T $Z

MS012_X="$GEN bw=3.90 cw=6.00 e=1.27 plc=5.40"
MS012="$MS012_X pw=0.60"
MS012_T="$MS012_X pw=0.55"

D='dimensions-based-on=Microchip Packaging Specification DS00000049BR'

Y='SOIC-8 narrow, 3.9mm-wide (JEDEC MS-012-AA)'
Z='np=8 bl=4.90 pl=1.55'
AKA="`akas SOIC8 MS012AA`"
dil SOIC8_MS012AA "$Y" "$D" "$AKA" $MS012 $Z

Y='SOIC-14 narrow, 3.9mm-wide (JEDEC MS-012-AB)'
Z='np=14 bl=8.65 pl=1.50'
AKA="`akas SOIC14 MS012AB`"
dil SOIC14_MS012AB "$Y" "$D" "$AKA" $MS012 $Z

SOT23_6="$GEN bl=2.9 bw=1.5 cw=2.75 e=0.95 lw=0.325 pl=0.8 plc=2.4 pw=0.55 np=6"
Y='SOT23-6'
D='dimensions-based-on=http://www.nxp.com/documents/data_sheet/PMN27XPE.pdf'
AKA="`akas SOT23-6 SOT457 SC74 SuperSOT6 S6 SMT6 SMD6 TSMT6 TSOP6`"
dil "$Y" "$Y" "$D" "$AKA" $SOT23_6
dil "$Y"_DDGSDD "$Y, DDGSDD" "$D" "$AKA" $SOT23_6 1=D 2=D 3=G 4=S 5=D 6=D
dil "$Y"_G1S2G2D2S1D1 "$Y, G1S2G2D2S1D1" "$D" "$AKA" $SOT23_6 1=G1 2=S2 3=G2 4=D2 5=S1 6=D1

SC70_6="$GEN bl=2 bw=1.25 cw=2.1 e=0.65 lw=0.2 pl=0.7 plc=1.6 pw=0.3 np=6"
Y='SC70-6'
D='dimensions-based-on=http://www.infineon.com/cms/packages/SMD_-_Surface_Mounted_Devices/SOT/SOT363_xSC88x.html?__locale=en'
AKA="`akas SC70-6 SOT363 SC88 UMT6 UMD6 TUMT6 US6`"
dil "$Y" "$Y" "$D" "$AKA" $SC70_6
# Footprint for 2N7002DW dual NMOS
dil "$Y"_S1G1D2S2G2D1 "$Y, S1G1D2S2G2D1" "$D" "$AKA" $SC70_6 1=S1 2=G1 3=D2 4=S2 5=G2 6=D1

for i in 3 4 5 6 7 8 10 12 13 15 17 20 22 25 30 32; do
	Y="Header, ${i}x2, 100mil pitch, shrouded, notched"
	box_notch_header Box_header_100mil_notch_"$i"x2 "$Y, ribbon cable numbering" $i 2
	box_notch_header Box_header_100mil_notch_"$i"x2_DIP "$Y, DIP pin numbering" $i 2 dip
done


# These "universal breakout" footprints are designed so that narrower variants
# of the same kind of package can still be attached—the idea being that
# generic breakout boards can use them.

Y='SOIC-28 universal breakout footprint'
Z="$GEN bw=7.50 cw=10.00 pw=0.60 e=1.27 pxl=11.6 g=3.4 np=28 bl=17.90"
dil_to universal-breakout SOIC28_universal_breakout "$Y" $Z

Y='SSOP-28 universal breakout footprint'
Z="$GEN bw=5.3 cw=7.8 pw=0.43 e=.65 pxl=9.0 g=3.9 np=28 bl=10.2"
dil_to universal-breakout SSOP28_universal_breakout "$Y" $Z
