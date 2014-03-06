#!/usr/bin/perl

# Please refer to the copyright notice at the end of this file.

use warnings;
use strict;
use Carp;
use 5.010;

use GEDA::PCB::Footprint::Twopad;

my %params = ();
my @comments = ();

push @comments, "\n";
push @comments, "# Generated footprint using 2pad.pl\n";

for(@ARGV) {
	if(/^\s*(.*?)\s*=(.*)$/) {
		my $k = $1;
		my $v = $2;
		if(exists($params{$k}) and $params{$k} ne $v) {
			croak "Conflicting values for parameter $k: $params{$k} vs. $v";
		}
		$params{$k} = $v;
		push @comments, "# $k = $v\n";
	}
	else {
		croak "Malformed parameter: $_";
	}
}

{
	my $gen = new GEDA::PCB::Footprint::Twopad %params;
	$params{format} //= 'pcb';
	
	given ($params{format}) {
		when('pcb') {
			print join('', @comments);
			$gen->write_footprint_to_handle;
		}
		when('eps') {
			binmode(select);
			$gen->write_eps_to_handle;
		}
		when('png') {
			binmode(select);
			$gen->write_png_to_handle;
		}
		default { croak "Parameter 'format' must be set to png, pcb, or eps"; }
	}
}

__END__

=head1 NAME

2pad.pl - a modest extension of DJ Delorie's 2-pad footprint generator

=head1 SYNOPSIS

	perl 2pad.pl key1=value1 ... keyN=valueN > output.fp

	# Example
	perl 2pad.pl \
		id=TWOPIN_EXAMPLE "description=Example two-pin device" \
		units=mm c=0.127 m=0.3 plc=1.9 pt=0.3 pw=1.6 so=0.2 sw=0.2

=head1 PARAMETERS

=head2 Output format

Note that the output is always printed to standard output, so make sure to
redirect it!

C<format> can be set to C<pcb> (default), C<eps>, or C<png>.

The C<eps> and C<png> options require the program C<pcb> to be installed and in
the path to perform the conversion to a vector graphic. The C<png> option also
requires Image::Magick to convert the graphic to PNG.

The scale of the PNG is set to approximate the size produced by the original
2pad.cgi script, which isn't necessarily useful. For more flexibility, choose
C<eps> instead and then run your own conversions.

=head2 Comment parameters

Keys not used in constructing elements are still echoed in the leading
comments, allowing additional text to be injected into the file. At least the
following keys are reserved to only have this meaning:

	dimensions-based-on
	url
	author
	copyright
	license

=head2 Generation parameters

Please refer to L<GEDA::PCB::Footprint::Twopad> for a description of the
parameters used in generating the footprint.

=head1 AUTHOR

Peter S. May, L<http://psmay.com/>

Based, by way of substantial refactoring, on 2pad.cgi by DJ Delorie.

=head1 COPYRIGHT

2pad.pl, a footprint generator for 2-pad surface-mount parts in gEDA pcb

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

