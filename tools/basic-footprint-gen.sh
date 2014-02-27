#!/bin/sh

DEST=../footprints

dil () {
	id="$1"
	shift
	desc="$1"
	shift
	./dilpad.pl id="$id" description="$desc" "$@" > "$DEST/$id.fp"
}

# see the dilpad.pl perldoc for the meanings of these parameters

GEN="units=mm seq=A c=5mil m=6.54mil so=10mil sw=10mil"
MO150_X="$GEN bw=5.3 cw=7.8 e=.65 pl=2.25 plc=6.55"
MO150="$MO150_X pw=0.43"
MO150_T="$MO150_X pw=0.38"

Y='SSOP-20 5.3mm-wide body (JEDEC MO-150-AE)'
Z='np=20 bl=7.2'
D='dimensions-based-on=National Semiconductor drawing (SC)MKT-MSA20 rev C'
dil SSOP20_MO150AE "$Y" "$D" $MO150 $Z
dil SSOP20_MO150AE_narrowed_pads "$Y, with narrowed 0.38mm pads" "$D" $MO150_T $Z

Y='SSOP-28 5.3mm-wide body (JEDEC MO-150-AH)'
Z='np=28 bl=10.2'
D='dimensions-based-on=National Semiconductor drawing (SC)MKT-MSA28 rev C'
dil SSOP28_MO150AH "$Y" "$D" $MO150 $Z
dil SSOP28_MO150AH_narrowed_pads "$Y, with narrowed 0.38mm pads" "$D" $MO150_T $Z

TSOP6="$GEN bl=2.9 bw=1.5 cw=2.75 e=0.95 lw=0.325 pl=0.8 plc=2.4 pw=0.55 np=6"
Y='TSOP-6'
D='dimensions-based-on=http://www.nxp.com/documents/data_sheet/PMN27XPE.pdf'
dil TSOP6 "$Y" "$D" $TSOP6
dil TSOP6_DDGSDD "$Y, DDGSDD" "$D" $TSOP6 1=D 2=D 3=G 4=S 5=D 6=D
dil TSOP6_G1S2G2D2S1D1 "$Y, G1S2G2D2S1D1" "$D" $TSOP6 1=G1 2=S2 3=G2 4=D2 5=S1 6=D1
