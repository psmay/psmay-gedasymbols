
package Rect;

# Copyright (c) 2014 Peter S. May
#
# The MIT license (as recognized by OSI):
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

use warnings;
use strict;
use 5.010;
use Carp;

sub new_sides {
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my($x1, $y1, $x2, $y2) = @_;
	if($x1 > $x2) {
		($x1, $x2) = ($x2, $x1);
	}
	if($y1 > $y2) {
		($y1, $y2) = ($y2, $y1);
	}
	return bless {
		lx => $x1,
		rx => $x2,
		ty => $y1,
		by => $y2,
	}, $class;
}

sub new {
	#say STDERR "new called with: @_";
	my $proto = shift;
	my $w = shift // 1.0;
	my $h = shift // 1.0;
	my $cx = shift // 0;
	my $cy = shift // 0;
	return $proto->new_sides($cx - ($w/2), $cy - ($h/2), $cx + ($w/2), $cy + ($h/2));
}

# Get left, top, right, bottom.
sub get_sides {
	my $self = shift;
	return ($self->{lx}, $self->{ty}, $self->{rx}, $self->{by});
}

# Redefine left, top, right, bottom by adjusting width/height.
sub stretched {
	my $self = shift;
	my $lx = shift // $self->{lx};
	my $ty = shift // $self->{ty};
	my $rx = shift // $self->{rx};
	my $by = shift // $self->{by};
	$self->new_sides($lx, $ty, $rx, $by);
}

# Same as stretched, but relative to current values.
sub stretched_by {
	my $self = shift;
	my $dlx = shift // 0;
	my $dty = shift // 0;
	my $drx = shift // 0;
	my $dby = shift // 0;
	my ($lx, $ty, $rx, $by) = $self->get_sides;
	$self->new_sides($lx+$dlx, $ty+$dty, $rx+$drx, $by+$dby);
}

# Redefine left, top, right, bottom by moving shape but retaining width/height.
sub aligned {
	my $self = shift;
	my($lx, $ty, $rx, $by) = @_;

	my @dx = ();
	my @dy = ();

	my($lx0, $ty0, $rx0, $by0) = $self->get_sides;

	push @dx, $lx - $lx0 if defined $lx;
	push @dx, $rx - $rx0 if defined $rx;
	push @dy, $ty - $ty0 if defined $ty;
	push @dy, $by - $by0 if defined $by;

	my $dx = undef;
	my $dy = undef;

	for(@dx) {
		if(defined $dx) {
			croak "Conflicting x alignment" unless $dx == $_;
		}
		$dx = $_;
	}

	for(@dy) {
		if(defined $dy) {
			croak "Conflicting y alignment" unless $dy == $_;
		}
		$dy = $_;
	}

	$self->move_by($dx, $dy);
}

# Get width, height, center-x, center-y.
sub get_whc {
	my $self = shift;
	return (
		$self->{rx} - $self->{lx},
		$self->{by} - $self->{ty},
		($self->{ty} + $self->{by}) / 2,
		($self->{lx} + $self->{rx}) / 2,
	);
}

# Redefine width, height, center-x, center-y.
sub resized {
	my $self = shift;
	my ($w0, $h0, $cx0, $cy0) = $self->get_whc;
	my $w = shift // $w0;
	my $h = shift // $h0;
	my $cx = shift // $cx0;
	my $cy = shift // $cy0;
	$self->new($w, $h, $cx, $cy);
}

# Same as resized, but relative to current values.
sub resized_by {
	my $self = shift;
	my $dw = shift // 0;
	my $dh = shift // 0;
	my $dcx = shift // 0;
	my $dcy = shift // 0;
	my ($w, $h, $cx, $cy) = $self->get_whc;
	$self->new($w+$dw, $h+$dh, $cx+$dcx, $cy+$dcy);
}

# Same as resized(undef, undef, cx, cy).
sub move {
	my $self = shift;
	my ($cx, $cy) = @_;
	$self->resized(undef, undef, $cx, $cy);
}

# Same as resized_by(undef, undef, dx, dy).
sub move_by {
	my $self = shift;
	my ($dx, $dy) = @_;
	$self->resized_by(undef, undef, $dx, $dy);
}

sub width { ($_[0]->get_whc)[0] }
sub height { ($_[0]->get_whc)[1] }
sub cx { ($_[0]->get_whc)[2] }
sub cy { ($_[0]->get_whc)[3] }
sub left { ($_[0]->get_sides)[0] }
sub top { ($_[0]->get_sides)[1] }
sub right { ($_[0]->get_sides)[2] }
sub bottom { ($_[0]->get_sides)[3] }

1;

