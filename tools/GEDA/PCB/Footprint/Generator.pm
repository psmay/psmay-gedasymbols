
# Please refer to the copyright notice at the end of this file.

package GEDA::PCB::Footprint::Generator;

use warnings;
use strict;
use Carp;
use 5.010;

use File::Temp 'tempdir';
use File::Spec;
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



## PCB format

sub _line {
	shift;
	# Generate ElementLine.
	my ($x1, $y1, $x2, $y2, $t) = @_;
	sprintf("\tElementLine[%d %d %d %d %d]\n",
			$x1, $y1, $x2, $y2, $t);
}

sub _arc {
	shift;
	# Generate ElementArc.
	my ($x, $y, $r, $sa, $da, $t) = @_;
	sprintf("\tElementArc[%d %d %d %d %d %d %d]\n",
			$x, $y, $r, $r, $sa, $da, $t);
}

sub _pad {
	shift;
	# Generate Pad.
	my ($a0, $a1, $a2, $a3, $a4, $a5, $a6, $lname, $rname, $flags) = @_;
	sprintf("\tPad[%d %d %d %d %d %d %d \"%s\" \"%s\" \"%s\"]\n",
		$a0, $a1, $a2, $a3, $a4, $a5, $a6, $lname, $rname, $flags);
}

sub _box {
	my $self = shift;
	# Generate a rectangle.
	my ($x1, $y1, $x2, $y2, $t) = @_;
	if (@_ == 3) {
		# Given only 3 parameters, draw centered on the origin.
		my ($w, $h, $t_) = @_;
		($x1, $y1, $x2, $y2, $t) = (-$w/2, -$h/2, $w/2, $h/2, $t_);
	}
	$self->_line($x1, $y1, $x1, $y2, $t) .
	$self->_line($x1, $y1, $x2, $y1, $t) .
	$self->_line($x2, $y2, $x1, $y2, $t) .
	$self->_line($x2, $y2, $x2, $y1, $t);
}

sub _element_head {
	shift;
	my ($s0, $description, $refdes, $val, $n1, $n2, $n3, $n4, $n5, $n6, $s1) = @_;
	
	return sprintf('Element["%s" "%s" "%s" "%s" %d %d %d %d %d %d "%s"]' . "\n(\n",
		$s0, $description, $refdes, $val, $n1, $n2, $n3, $n4, $n5, $n6, $s1);
}

sub _element_tail { ")\n" }

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

sub _parse_magnitude {
	my $value = shift;
	my $default_unit = shift;

	for($value) {
		$_ //= '';
		$_ = lc $_;
		s/\s+//;
		if (/^\s*([\d\.]+)\s*(?:(mil|mm|%|x)\s*)?$/i) {
			my $num = $1;
			my $unitname = $2 // '';
			my $unit = $default_unit;
			$unit = _get_inline_unit($unitname) if $unitname ne '';
			return ($num * $unit->{rate}, $unit->{relative});
		} else {
			return ();
		}
	}
}

sub _parse_magnitudes_from_input {
	my $in = shift;
	my @names = @_;

	my $mag = {};

	my $default_unit = _get_default_unit($in->{units});

	for my $v (@names) {
		my($mv, $mr) = _parse_magnitude($in->{$v}, $default_unit);
		if(defined $mv) {
			$mag->{V}{$v} = $mv;
			$mag->{R}{$v} = $mr;
		}
		else {
			delete $mag->{V}{$v};
		}
	}
	return $mag;
}

sub _parse_parameters {
	my $self = shift;
	my $in = { @_ };

	# load input parameters
	my $mag = _parse_magnitudes_from_input($in, $self->_get_magnitude_variable_names);
	# fill in missing parameters
	$self->_fill_in_missing_magnitudes($mag);
	$self->_fill_in_additional_parameters($mag, $in);
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
	$self->_initialize(@_);
	return $self;
}

sub _initialize {
	my $self = shift;
	return $self->_parse_parameters(@_);
}

sub DESTROY {
	my $self = shift;
	$self->_clear_temp_dir;
}

##
1;
##

__END__

=head1 NAME

GEDA::PCB::Footprint::Generator - a base footprint generator gEDA pcb

=head1 WARNING

This documentation has not been updated for the new structure.

=head1 METHODS

=over 4

=item $gen = GEDA::PCB::Footprint::Generator->new(I<%parameters>)

Creates a new generator object using the given parameters (see L<"PARAMETERS">);

=item $gen->write_footprint_to_handle([I<handle>])

Generates the element and writes it out to the given handle. If no handle is
given, the currently selected handle (by default, C<STDOUT>) is used.

=item $gen->write_eps_to_handle([I<handle>])

Generates the element, converts it to a vector graphic in EPS format, and
writes the result out to the given handle. If no handle is given, the currently
selected handle (by default, C<STDOUT>) is used.

Call C<binmode> on the destination handle before writing.

This conversion requires the program C<pcb> to be installed and in the path to
perform the conversion to a vector graphic.

=item $gen->write_png_to_handle([I<handle>])

Generates the element, converts it to a raster graphic in PNG format, and
writes the result out to the given handle. If no handle is given, the currently
selected handle (by default, C<STDOUT>) is used.

Call C<binmode> on the destination handle before writing.

This conversion requires the program C<pcb> to be installed and in the path to
perform the conversion to a vector graphic, and also requires Image::Magick to
convert the vector graphic to PNG.

The scale of the PNG is set to approximate the size produced by the original
dilpad.cgi script, which isn't necessarily useful. For more flexibility,
generate the EPS instead and then run your own conversions.

=back

=head1 PARAMETERS

Note that parameter names are case-sensitive.

=head2 Dimensions

Dimensions are given as numbers optionally followed by a unit C<mm>, C<mil>, or
(where applicable) C<%> or C<x>. If no unit is given, the default unit (set by
the C<units> parameter). Unitless values can be supplied as a number (e.g.
C<2.13>) or a string (e.g. C<'2.13'>), but a value with a unit must be a string
with the unit after the number (e.g. C<'2.13mm'>).

Some parameters can be supplied as a percentage (C<%>) or ratio (C<x>) of some
other value; these are indicated below as C<can be % of>. For example, if
C<ple> is defined as C<213%> (or, equivalently, C<2.13x>), its value will be
defined as 2.13 times the defined value for C<ll>.

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
	... and so forth for any base-10
	    natural number without leading 0s ...

=head2 Other

	id = the value parameter for the element
	description = the description parameter for the element
	
	pol = draw physical outline (tested as boolean)

Keys not used in constructing elements are ignored; in the example script, they
are included in the output as comments, allowing additional text to be injected
into the file. At least the following keys are reserved to only have this
understood meaning:

	dimensions-based-on
	url
	author
	copyright
	license

=head1 AUTHOR

Peter S. May, L<http://psmay.com/>

Based, by way of substantial refactoring, on dilpad.cgi by DJ Delorie.

=head1 COPYRIGHT

GEDA::PCB::Footprint::Generator, a footprint generator for surface-mount DIL parts in gEDA pcb

Copyright (C) 2008-2014 DJ Delorie, Peter S. May

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see L<http://www.gnu.org/licenses/>.

=cut
