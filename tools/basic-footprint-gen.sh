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

dil () {
	id="$1"
	shift
	desc="$1"
	shift
	footprint-dilpad id="$id" description="$desc" \
		author="$AUTHOR" email="$EMAIL" dist-license="$DIST_LICENSE" use-license="$USE_LICENSE" \
		"@gedasymbols::url=$URL_DEST/$id.fp" \
		"$@" > "$DEST/$id.fp"
}

akas () {
	perl -E '$z{$_} = 1 for @ARGV; say "aka=" . join(", ", sort keys %z)' "$@"
}

# see the dilpad.pl perldoc for the meanings of these parameters

GEN="units=mm seq=A c=10mil m=10mil so=10mil sw=10mil"

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

