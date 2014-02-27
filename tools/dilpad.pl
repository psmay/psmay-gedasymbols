#!/usr/bin/perl
# -*- perl -*-

package Dilpad;

use warnings;
use strict;
use Carp;
use 5.010;

use File::Temp 'tempdir';
use File::Spec;
use List::Util qw/min max first/;
use Image::Magick;

my $PCB = `which pcb`;
chomp $PCB;

sub MM() { 1000/25.4 * 100 }
sub MIL() { 100 }

my %unit_rates = (
	mm => { rate => MM, name => 'mm' },
	mil => { rate => MIL, name => 'mil' },
	'' => { rate => 1, name => '' },
	'%' => { rate => 0.01, relative => 1, name => '%' },
	x => { rate => 1, relative => 1, name => 'x' },
);

sub _get_default_unit {
	my $name = lc(shift // '');
	$name = ''
		unless defined($unit_rates{$name})
		&& !$unit_rates{$name}{relative};
	$name = 'mil' if $name eq '';
	return $unit_rates{$name};
}

sub _get_inline_unit {
	my $name = lc(shift // '');
	$name = ''
		unless defined($unit_rates{$name});
	return $unit_rates{$name};
}


## External processes

sub _run_with_check {
	# Run a shell command and discard output. Croak (with output) on failure.
	my ($cmd) = @_;
	my ($rv, $msg);
	my $ph;
	local $/;
	open($ph, "$cmd 2>&1 |") or croak "Run failed for $cmd: $!";
	$msg = <$ph>;
	if ($?) {
		croak qq(Command "$cmd" failed:\n$msg);
	}
	close($ph);
}

sub _run_pcb_fp_to_eps {
	# Run shell command to convert fp to eps.
	my $fpfilename = shift;
	my $epsfilename = shift;
	_run_with_check("$PCB -x eps --eps-file $epsfilename --only-visible $fpfilename");
}



## Utility

sub _round {
	# Round to nearest, choosing the higher number at .5.
	my $value = shift;
	return undef unless defined $value;
	use POSIX 'floor';
	return floor($value + 0.5);
}

sub _firstz {
	# Returns first true argument, or 0.
	return +(first { $_ } @_) or 0;
}




## PCB format

sub _line {
	# Generate ElementLine.
	my ($x1, $y1, $x2, $y2, $t) = @_;
	sprintf("\tElementLine[%d %d %d %d %d]\n",
			$x1, $y1, $x2, $y2, $t);
}

sub _arc {
	# Generate ElementArc.
	my ($x, $y, $r, $sa, $da, $t) = @_;
	sprintf("\tElementArc[%d %d %d %d %d %d %d]\n",
			$x, $y, $r, $r, $sa, $da, $t);
}

sub _pad {
	# Generate Pad.
	my ($a0, $a1, $a2, $a3, $a4, $a5, $a6, $lname, $rname, $flags) = @_;
	sprintf("\tPad[%d %d %d %d %d %d %d \"%s\" \"%s\" \"%s\"]\n",
		$a0, $a1, $a2, $a3, $a4, $a5, $a6, $lname, $rname, $flags);
}

sub _box {
	# Generate a rectangle.
	my ($x1, $y1, $x2, $y2, $t) = @_;
	if (@_ == 3) {
		# Given only 3 parameters, draw centered on the origin.
		my ($w, $h, $t_) = @_;
		($x1, $y1, $x2, $y2, $t) = (-$w/2, -$h/2, $w/2, $h/2, $t_);
	}
	_line($x1, $y1, $x1, $y2, $t) .
	_line($x1, $y1, $x2, $y1, $t) .
	_line($x2, $y2, $x1, $y2, $t) .
	_line($x2, $y2, $x2, $y1, $t);
}

sub _with_silk_around_footprint {
	my %q = @_;

	# Not enough space for silk in the middle, put it around the whole
	# footprint.
	my $w = max($q{bw}, $q{cw}+$q{s}, $q{pxl}+$q{s})/2;
	my $r = max($q{soc}, ($q{bl} - ($q{e}*($q{np2}-1)+$q{pw}))/2);

	return
		_line(-$w+$r, -$q{l}, $w, -$q{l}, $q{t}) .
		_line(-$w, $q{l}, $w, $q{l}, $q{t}) .
		_line( $w, -$q{l}, $w, $q{l}, $q{t}) .
		_line(-$w, $q{l}, -$w, -$q{l}+$r, $q{t}) .
		_arc(-$w+$r, -$q{l}+$r, $r, 270, 90, $q{t});
}

sub _with_silk_between_pads {
	my %q = @_;

	# Enough space to put the silk between the pads.
	my $w1 = _firstz($q{bw}, $q{cw}+$q{s}, $q{pxl}+$q{s})/2;
	my $w2 = min($q{bw}/2, $q{g}/2-$q{soc});

	my $r;
	$r = $q{g}/6;
	$r = min($r, $q{l}-$q{s});
	$r = min($r, $w2);
	$r = max($r, $q{sw}/2 + $q{so}/2);

	return
		_arc (0, -$q{l}, $r, 0, 180, $q{t}) .

		_line(-$w1, -$q{l}, -$r, -$q{l}, $q{t}) .
		_line($r, -$q{l}, $w1, -$q{l}, $q{t}) .
		_line(-$w1, $q{l}, $w1, $q{l}, $q{t}) .

		_line( $w2, -$q{l}, $w2, $q{l}, $q{t}) .
		_line(-$w2, $q{l}, -$w2, -$q{l}, $q{t});
}

sub _seq_pin_location {
	my $pad_number = shift;
	my $pad_count_half = shift;
	my $seq = uc(shift // '');
	if($seq eq '') {
		$seq = "A";
		carp "No seq provided; reverting to $seq";
	}
	if($seq !~ /^[A-F]$/) {
		croak "Unknown sequence type $seq";
	}

	my $pad_count = $pad_count_half * 2;

	my $left = ($pad_number <= $pad_count_half);

	my ($ix, $iy);

	if ($seq =~ /A/i) {
		$ix = $left ? 0 : 1;
		$iy = $left ? $pad_number-1 : $pad_count-$pad_number;
	} elsif ($seq =~ /B/i) {
		$ix = $left ? 0 : 1;
		$iy = $left ? $pad_number-1 : $pad_number-$pad_count_half-1;
	} elsif ($seq =~ /C/i) {
		$ix = ($pad_number-1) % 2;
		$iy = int(($pad_number-1) / 2);
	} elsif ($seq =~ /D/i) {
		$ix = $left ? 1 : 0;
		$iy = $left ? $pad_number-1 : $pad_count-$pad_number;
	} elsif ($seq =~ /E/i) {
		$ix = $left ? 1 : 0;
		$iy = $left ? $pad_number-1 : $pad_number-$pad_count_half-1;
	} elsif ($seq =~ /F/i) {
		$ix = 1 - ($pad_number-1) % 2;
		$iy = int(($pad_number-1) / 2);
	} else {
		croak "Invalid sequence type $seq";
	}

	return ($ix, $iy);
}

sub _package_outline {
	my %q = @_;

	my @output;

	if (defined($q{bw}) && defined($q{bl})) {
		push @output, _box($q{bw}, $q{bl}, 1);
	}

	if (defined($q{cw}) && defined($q{lw}) && defined($q{bw})) {
		for my $p (0 .. $q{np2} - 1) {
			push @output, _box(-$q{cw}/2, $q{pad1y}-$q{lw}/2+$q{p}*$q{e}, -$q{bw}/2, $q{pad1y}+$q{lw}/2+$q{p}*$q{e}, 100);
			push @output, _box($q{cw}/2, $q{pad1y}-$q{lw}/2+$q{p}*$q{e}, $q{bw}/2, $q{pad1y}+$q{lw}/2+$q{p}*$q{e}, 100);
		}
	}

	return join('', @output);
}

sub _element_head {
	my ($s0, $description, $refdes, $val, $n1, $n2, $n3, $n4, $n5, $n6, $s1) = @_;
	
	return sprintf('Element["%s" "%s" "%s" "%s" %d %d %d %d %d %d "%s"]' . "\n(\n",
		$s0, $description, $refdes, $val, $n1, $n2, $n3, $n4, $n5, $n6, $s1);
}

sub _element_tail { ")\n" }

sub _element {
	my $self = shift;
	my %q = @_;

	my @output = ();

	#push @output, get_comments();


	push @output, _element_head("", $q{description}, $q{refdes}, $q{id}, 0, 0, 0, 0, 0, 100, "");

	# $ix and $iy are 0 for the upper left pad.
	my ($ix, $iy);

	my $pad1y = - ($q{np2}-1) * $q{e} / 2;

	for my $pad (1..$q{np}) {
		($ix, $iy) = _seq_pin_location($pad, $q{np2}, $q{seq});

		my $x = $ix ? 1 : -1;
		my $y = $pad1y + $q{e} * $iy;

		my $pinname = $q{pinnames}{$pad};
		my $pinnumber = $q{pinnumbers}{$pad};

		push @output, _pad($x*($q{px}+$q{dx}), $y+$q{dy}, $x*($q{px}-$q{dx}),
			$y-$q{dy}, $q{pt}, $q{c}*2, $q{m}*2 + $q{pt}, $pinname, $pinnumber, "square");
	}

	if ($q{pol}) {
		push @output, _package_outline(pad1y => $pad1y, %q);
	}

	if ($q{g} < 3 * $q{so} + 2 * $q{sw} || $q{bw} == 0 || $q{bl} == 0) {
		push @output, _with_silk_around_footprint(%q);
	} else {
		push @output, _with_silk_between_pads(%q);
	}

	push @output, _element_tail();

	return join('', @output);
}

sub render_element {
	my $self = shift;
	print $self->_element(@_);
}




## PNG generation

sub _white_image {
	my $src = shift;
	my $geom = $src->Get('width') . 'x' . $src->Get('height');

	my $image = new Image::Magick size => $geom;
	$image->Read('xc:#ffffff');
	return $image;
}

sub _get_magick_for_eps {
	my $epsfilename = shift;

	my $oversample = 10;

	my $eps_scale = _get_eps_scale($epsfilename);

	# The original script produces something roughly 2.5% larger than
	# specified. Haven't determined why, but we'll play along for
	# compatibility.
	my $image_scale = $eps_scale * 1.025 / $oversample;

	my $p = new Image::Magick;

	# Read oversized to prevent undersampling
	my $osp = $oversample * 100;
	$p->Set('density', "${osp}x${osp}");

	$p->Read($epsfilename);

	# Fill in transparent background
	$p->Composite(compose => 'dst-over', image => _white_image($p));

	$p->Scale("$image_scale%");

	return $p;
}

sub _get_eps_scale {
	my $filename = shift;
	my $fh;
	open($fh, $filename);
	my $scale = 100;
	while (<$fh>) {
		if (/BoundingBox: \d+ \d+ (\d+) (\d+)/) {
			$scale = int(200 * 100 / max($1, $2));
			last;
		}
	}
	close $fh;
	return $scale;
}


## I/O and conversion

sub _write_footprint_at {
	my $self = shift;
	my $filename = shift;
	my %additional = @_;

	my $fp;
	open($fp, ">", $filename);
	my $oldfp = select $fp;

	my %q = $self->_footprint_parameters();

	$self->render_element(%additional, %q);

	select $oldfp;
	close $fp;
}

sub _as_footprint_temp {
	my $self = shift;
	if(not exists $self->{temp_files}{fp}) {
		my $filename = $self->_temp_file("fp.fp");
		$self->_write_footprint_at($filename, @_);	
		$self->{temp_files}{fp} = $filename;
	}
	return $self->{temp_files}{fp};
}

sub write_footprint_to_handle {
	my $self = shift;
	my $outhandle = shift;
	return _cat_to_handle($self->_as_footprint_temp(@_), $outhandle);
}


sub _write_eps_at {
	my $self = shift;
	my $filename = shift;
	my $fpfilename = $self->_as_footprint_temp(@_);
	_run_pcb_fp_to_eps($fpfilename, $filename);
}

sub _as_eps_temp {
	my $self = shift;
	if(not exists $self->{temp_files}{eps}) {
		my $filename = $self->_temp_file("eps.eps");
		$self->_write_eps_at($filename, @_);
		$self->{temp_files}{eps} = $filename;
	}
	return $self->{temp_files}{eps};
}

sub write_eps_to_handle {
	my $self = shift;
	my $outhandle = shift;
	return _cat_to_handle($self->_as_eps_temp(@_), $outhandle);
}



sub _write_png_at {
	my $self = shift;
	my $filename = shift;

	my $magick = _get_magick_for_eps($self->_as_eps_temp(@_));
	$magick->Write($filename);
	return $filename;
}

sub _as_png_temp {
	my $self = shift;
	if(not exists $self->{temp_files}{png}) {
		my $filename = $self->_temp_file("png.png");
		$self->_write_png_at($filename, @_);
		$self->{temp_files}{png} = $filename;
	}
	return $self->{temp_files}{png};
}

sub write_png_to_handle {
	my $self = shift;
	my $outhandle = shift;
	return _cat_to_handle($self->_as_png_temp(@_), $outhandle);
}

# Creates a temp dir, if one does not already exist
sub _temp_dir {
	my $self = shift;
	my $dont_create = shift;
	if(not defined $self->{temp_dir} and not $dont_create) {
		$self->{temp_dir} = tempdir(CLEANUP => 1);
	}
	return $self->{temp_dir};
}

sub _temp_file {
	my $self = shift;
	my $name = shift;
	return File::Spec->catfile($self->_temp_dir(), $name);
}

sub _clear_temp_files {
	my $self = shift;
	if(defined $self->{temp_files}) {
		for(keys %{$self->{temp_files}}) {
			unlink $self->{temp_files}{$_};
		}
		delete $self->{temp_files};
	}
}

sub _clear_temp_dir {
	my $self = shift;
	$self->_clear_temp_files;
	if(defined $self->{temp_dir}) {
		unlink $self->{temp_dir};
		delete $self->{temp_dir};
	}
}

sub _current_handle() {
	my $h = select;
	if(not ref $h) {
		no strict 'refs';
		$h = \*{$h};
	}
	return $h;
}

sub _cat_to_handle {
	my $filename = shift;
	my $oh = shift;

	$oh = _current_handle unless defined $oh;

	{
		local $/;
		my $fh;
		open($fh, '<', $filename);
		while(<$fh>) {
			print $oh $_;
		}
		close $fh;
	}

	return $oh;
}




## Computation of parameters

# In a mag table, if d is a ratio, calculate it in terms of s.
sub _fill_in_ratio {
	my $mag = shift;
	my ($d, $s) = @_;
	return 0 unless defined($mag->{V}{$d}) and $mag->{R}{$d};
	if (defined($mag->{V}{$s}) and not $mag->{R}{$s}) {
		my $conv = $mag->{V}{$d} * $mag->{V}{$s};
		$mag->{V}{$d} = _round($conv);
		delete $mag->{R}{$d};
		return 1;
	}
	return 0;
}

sub _fp(@) {
	my $mag = shift;
	_fill_in_ratio($mag, @_);
}

# In a mag table, if the destination is not already defined, calculate it in
# terms of the remaining operands using the given function.
sub _fill_in_calculation {
	my $mag = shift;
	my $fn = shift;
	my $dest_name = shift;
	
	# Skip if destination is already set.
	return 0 if defined($mag->{V}{$dest_name});

	my @param_values = ();

	for(@_) {
		# Skip if any parameter is unset.
		return 0 unless defined($mag->{V}{$_});

		# Skip if any parameter is a ratio.
		return 0 if $mag->{R}{$_};

		push @param_values, $mag->{V}{$_};
	}

	my $result = _round($fn->(@param_values));
	$mag->{V}{$dest_name} = $result;
	return 1;
}

sub _fc(&@) {
	my $fn = shift;
	my $mag = shift;
	_fill_in_calculation($mag, $fn, @_);
}

sub _parse_magnitudes_from_input {
	my $in = shift;
	my $mag = {};

	my $default_unit = _get_default_unit($in->{units});

	for my $v (qw/bl bw c cw e g ll lw m pg pl plc ple pw pwe pxl so soc sw/) {
		my $upv = uc $v;
		if ($in->{$v}) {
			#add_comment("$upv = $in->{$v}");
		}
		$in->{$v} //= '';
		$in->{$v} =~ s/\s+//;
		$in->{$v} =~ lc $in->{$v};
		if ($in->{$v} =~ /^([\d\.]+)(mil|mm|%|)/) {
			my $num = $1;
			my $u = $2;
			my $unit = $default_unit;
			$unit = _get_inline_unit($u) if $u ne '';
			$mag->{V}{$v} = $num * $unit->{rate};
			$mag->{R}{$v} = $unit->{relative};
		} else {
			delete $mag->{V}{$v};
		}
	}
	return $mag;
}

sub _fill_in_missing_magnitudes {
	my $mag = shift;

	FILL_IN_BLANKS: {
		my $again = 0;

		$again |= _fp $mag, 'g', 'bw';
		$again |= _fp $mag, 'pwe', 'lw';
		$again |= _fp $mag, 'ple', 'll';

		$again |= _fc { my ($bw, $ll) = @_; $bw + 2 + $ll } $mag, qw/cw bw ll/;
		$again |= _fc { my ($bw, $ll) = @_; $bw + 2 * $ll } $mag, qw/cw bw ll/;
		$again |= _fc { my ($pxl, $ll) = @_; $pxl - 2 * $ll } $mag, qw/cw pxl ll/;
		$again |= _fc { my ($pxl, $pl) = @_; $pxl - 2 * $pl } $mag, qw/g pxl pl/;
		$again |= _fc { my ($plc, $pl) = @_; $plc - $pl } $mag, qw/g plc pl/;
		$again |= _fc { my ($plc, $pl) = @_; $plc + $pl } $mag, qw/pxl plc pl/;
		$again |= _fc { my ($g, $pl) = @_; $g + 2 * $pl } $mag, qw/pxl g pl/;
		$again |= _fc { my ($plc, $pl) = @_; $plc + $pl } $mag, qw/pxl plc pl/;
		$again |= _fc { my ($cw, $ple) = @_; $cw + 2 * $ple } $mag, qw/pxl cw ple/;
		$again |= _fc { my ($pxl, $cw) = @_; ($pxl - $cw)/2 } $mag, qw/ple pxl cw/;

		$again |= _fc { my ($pw, $pwe) = @_; $pw - 2 * $pwe } $mag, qw/lw pw pwe/;
		$again |= _fc { my ($pw, $lw) = @_; ($pw - $lw)/2 } $mag, qw/pwe pw lw/;
		$again |= _fc { my ($lw, $pwe) = @_; $lw + 2 * $pwe } $mag, qw/pw lw pwe/;
		$again |= _fc { my ($e, $pg) = @_; $e - $pg } $mag, qw/pw e pg/;
		$again |= _fc { my ($e, $pw) = @_; $e - $pw } $mag, qw/pg e pw/;
		$again |= _fc { my ($pw, $pg) = @_; $pw + $pg } $mag, qw/e pw pg/;

		$again |= _fc { my ($pxl, $pl) = @_; $pxl - $pl } $mag, qw/plc pxl pl/;
		$again |= _fc { my ($g, $pl) = @_; $g + $pl } $mag, qw/plc g pl/;
		$again |= _fc { my ($cw, $ple, $pl) = @_; $cw + 2 * $ple - $pl } $mag, qw/plc cw ple pl/;
		$again |= _fc { my ($pxl, $g) = @_; ($pxl - $g)/2 } $mag, qw/pl pxl g/;
		$again |= _fc { my ($plc, $g) = @_; $plc - $g } $mag, qw/pl plc g/;
		$again |= _fc { my ($cl, $ple, $g) = @_; ($cl + $ple*2 - $g)/2 } $mag, qw/pl cl ple g/;

		$again |= _fc { my ($soc, $sw) = @_; $soc - $sw/2 } $mag, qw/so soc sw/;
		$again |= _fc { my ($so, $sw) = @_; $so + $sw/2 } $mag, qw/soc so sw/;
		$again |= _fc { my ($soc, $so) = @_; ($soc - $so)*2 } $mag, qw/sw soc so/;

		redo FILL_IN_BLANKS if $again;
	}

	_fp $mag, 'c', 'pg';
	_fp $mag, 'm', 'pg';
}

sub _parse_parameters {
	my $self = shift;
	my $in = { @_ };

	# load input parameters
	my $mag = _parse_magnitudes_from_input($in);
	# fill in missing parameters
	_fill_in_missing_magnitudes($mag);

	# variables based on $in
	my $seq = $in->{seq};
	my $pol = $in->{pol};

	my $np = $in->{np};
	croak "Number of pins (np) is not defined" unless defined $np;
	my $np2 = $np/2;

	my %pinnames = ();
	my %pinnumbers = ();
	for(1 .. $np) {
		$pinnames{$_} = $in->{"name$_"} // $_;
		$pinnumbers{$_} = $in->{$_} // $_;
	}

	my $description = $in->{description} // "dil-$np";
	my $refdes = $in->{refdes} // "U?";
	my $id = $in->{id};

	# variables based on $mag
	my $mv = $mag->{V};


	my $dx = 0;
	my $dy = 0;
	my $px = $mv->{plc} / 2;
	my $pt;

	if ($mv->{pl} > $mv->{pw}) {
		$dx = ($mv->{pl} - $mv->{pw}) / 2;
		$pt = $mv->{pw};
	} else {
		$dy = ($mv->{pw} - $mv->{pl}) / 2;
		$pt = $mv->{pl};
	}

	my $s = $mv->{soc} * 2;
	my $t = $mv->{sw};
	my $l = max($mv->{bl}, $mv->{e}*($np2-1)+$mv->{pw}+$s)/2;

	# footprint generation parameters
	$self->{generation_parameters} = {
		description => $description,
		refdes => $refdes,
		id => $id,
		pinnames => \%pinnames,
		pinnumbers => \%pinnumbers,
		np2 => $np2,
		np => $np,
		seq => $seq,
		pol => $pol,
		px => $px,
		dx => $dx,
		dy => $dy,
		pt => $pt,
		l => $l,
		t => $t,
		s => $s,
	};

	for(qw/bl bw c cw e g lw m pw pxl soc so sw/) {
		$self->{generation_parameters}{$_} = $mv->{$_};
	}
}

sub _footprint_parameters {
	my $self = shift;
	return %{$self->{generation_parameters}};
}


## Object

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $self = bless {}, $class;

	$self->_parse_parameters(@_);

	return $self;
}


sub DESTROY {
	my $self = shift;
	$self->_clear_temp_dir;
}

##
1;
##

package main;

use warnings;
use strict;
use Carp;
use 5.010;

my %params = ();

print "\n";
print "# Generated footprint using dilpad.pl\n";

for(@ARGV) {
	if(/^(.*?)=(.*)$/) {
		my $k = $1;
		my $v = $2;
		if(exists($params{$k}) and $params{$k} ne $v) {
			croak "Conflicting values for parameter $k: $params{$k} vs. $v";
		}
		$params{$k} = $v;
		print "# $k = $v\n";
	}
	else {
		croak "Malformed parameter: $_";
	}
}

{
	my $dp = new Dilpad %params;
	$params{format} //= 'pcb';
	
	given ($params{format}) {
		when('pcb') { $dp->write_footprint_to_handle; }
		when('eps') { $dp->write_eps_to_handle; }
		when('png') { $dp->write_png_to_handle; }
		default { croak "Parameter 'format' must be set to png, pcb, or eps"; }
	}

	$dp = undef;
}

__END__

=head1 NAME

dilpad.pl - a modest extension of DJ Delorie's DIL footprint generator

=head1 SYNOPSIS

	perl dilpad.pl I<key1>=I<value1> ... I<keyN>=I<valueN> > I<output>.fp

	# Example: One possibility for SSOP-28
	perl dilpad.pl \
		id=SSOP28 "description=SSOP-28 (JEDEC MP-150-AH)" \
		units=mm seq=A c=0.127 m=0.3 so=0.2 sw=0.6 \
		bw=5.3 cw=7.8 e=0.65 pl=2.25 plc=6.55 pw=0.43 \
		np=28 bl=10.2

=head1 PARAMETERS

dilpad.pl uses the same names as the original, except all lower case, and with
some additions.

=head2 Output format

Note that the output is always printed to standard output, so make sure to
redirect it!

C<format> can be set to C<pcb> (default), C<eps>, or C<png>.

The C<eps> and C<png> options require the program C<pcb> to be installed and in
the path to perform the conversion to a vector graphic. The C<png> option also
requires Image::Magick to convert the graphic to PNG.

The scale of the PNG is set to approximate the size produced by the original
dilpad.cgi script, which isn't necessarily useful. For more flexibility, choose
C<eps> instead and then run your own conversions.

=head2 Dimensions

Dimensions are given as numbers optionally followed by a unit C<mm>, C<mil>, or
(where applicable) '%'. If no unit is given, the default unit (set by the
C<units> parameter).

In the following descriptions,

=over 4

=item *

The B<end> of a pin or pad is a side that is facing toward or away from the
body of the device. (Two opposite pads have facing ends.)

=item *

The B<edge> of a pin or pad is a side that is perpendicular to the body of the
device. (Two adjacent pads have facing edges.)

=item *

The B<physical bound> is the smallest rectangle containing both the body and
all of the pads.

=back

	bl = body length
	bw = body width
	np = number of pins (required)

	cw = component width (between opposing ends of opposite pins)
	pxl = pad extents length (between opposing ends of opposite pads)
	g = gap (between facing ends of opposite pads, can be % of bw)
	plc = pad length, center-to-center (between centers of opposite pads)

	e = pitch (between centers of adjacent pads)
	pg = pad gap (between facing edges of adjacent pads)
	pw = pad width (between edges of single pad)
	lw = lead width (between edges of single pin)

	ll = lead length (between ends of single pin)
	pl = pad length (inner to outer edge of a pad)
	ple = pad length extension (between end of pin and matching end of pad,
		can be % of ll)
	pwe = pad width extension (between edge of pin and matching edge of pad,
		can be % of lw)

	so = silk offset (between physical bound and near edge of silk line)
	soc = silk offset to center (between physical bound and
		center of silk line)
	sw = silk width (thickness of silk line)

	c = clearance (between copper and polygon fill, can be % of pg)
	m = mask (between copper and mask, can be % of pg)

=head2 Sequence

	seq = numbering sequence type A-F, as follows:

		 A      B      C      D      E      F 
		1 8    1 5    1 2    8 1    5 1    2 1
		2 7    2 6    3 4    7 2    6 2    4 3
		3 6    3 7    5 6    6 3    7 3    6 5
		4 5    4 8    7 8    5 4    8 4    8 7

C<A> is the correct value for most ICs.

=head2 Pin names and numbers

The B<name> of a pin is simply arbitrary descriptive text.

The B<number> of a pin is the index by which nets are connected (corresponding
to the C<pinnumber> attribute in the schematic). Despite the name, this can be
alphanumeric.

Neither name nor number need be unique. Pads that are internally connected
might be given the same number in order to simplify the schematic symbol. For
example, one common 6-pin MOSFET pinout has 4 pins all connected to the drain,
so it might make sense to number all four of those pins as C<D>, and then
number the gate and source as C<G> and C<S> respectively. Some schematic
symbols already have pinnumbers compatible with this.

	1 = number for pin 1 (default 1)
	name1 = name for pin 1 (default 1)
	2 = number for pin 2 (default 2)
	name2 = name for pin 2 (default 2)
	... and so forth for any base-10 natural number without leading 0s ...

=head2 Other

	id = the value parameter for the element
	description = the description parameter for the element
	
	pol = draw physical outline (for false, omit or set to blank or 0)

Keys not used in constructing elements are still echoed in the leading
comments, allowing additional text to be injected into the file. At least the
following keys are reserved to only have this meaning:

	dimensions-based-on
	url
	author
	copyright
	license

=head1 AUTHOR

Peter S. May <http://psmay.com>

Based, by way of substantial refactoring, on dilpad.cgi by DJ Delorie.

=cut
