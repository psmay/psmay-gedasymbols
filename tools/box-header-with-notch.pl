#! /usr/bin/perl

use warnings;
use strict;
use 5.010;
use Carp;

use Rect;

# Loosely based on data sheet for SBH11-PBPC-Dxx-ST-xx


my %params = (
	columns => undef,
	id => '',
	description => '',
	rows => 2,
	dip => 0,
);

my @attributes = ();

for(@ARGV) {
	my($key,$value);

	if(/^@(.*?)=(.*)$/) {
		push @attributes, $1, $2;
		next;
	}

	if(/^(.*?)=(.*)$/) {
		$key = $1;
		$value = $2;
	} else {
		$key = $_;
		$value = $_;
	}

	if(not exists $params{$key}) {
		croak "Unknown parameter $key";
	} else {
		$params{$key} = $value;
	}
}

if (not defined $params{columns}) {
	croak "columns parameter required";
}

my $columns = int($params{columns});
my $rows = int($params{rows});
my $dip_numbering = !!$params{dip};

if($dip_numbering and $rows != 2) {
	croak "DIP numbering only applicable for 2 rows";
}

my $unit = 'mm';
my $mm_per_mil = 0.0254;
my $units_per_mil = $mm_per_mil;


sub mil_unit($) {
	$_[0] * $units_per_mil;
}


sub ceil_to {
	my $value = shift;
	my $multiple_of = shift;
	use POSIX 'ceil';
	return $multiple_of * ceil($value / $multiple_of);
}

# 

my $text_scale_each = mil_unit(0.40);
my $text_scale = 100;
my $text_height = $text_scale_each * $text_scale;

my $pin_rect = Rect->new(mil_unit(100 * ($columns - 1)), mil_unit(100 * ($rows - 1)));
my $inner_rect = $pin_rect->resized_by(mil_unit(305), 3.96);
my $bevel_rect = $inner_rect->resized_by(1.00, 1.00);
my $outer_rect = $pin_rect->resized_by(mil_unit(395), 6.26);

# The notch rect shares a center-x and a bottom with the outer rect.
my $notch_rect = $outer_rect
	->resized(4.50, 1.85)
	->aligned(undef, undef, undef, $outer_rect->bottom);

my $outline_thick = mil_unit(10);
my $element_rect = $outer_rect->resized_by($outline_thick, $outline_thick);


my $mark_x = $element_rect->cx - $element_rect->left;
my $mark_y = $element_rect->cy - $element_rect->top;
my $text_x = $inner_rect->left + $outline_thick;
my $text_y = $inner_rect->bottom - (2 * $outline_thick);

my @element_xys = map { "$_$unit" } ($mark_x, $mark_y, $text_x, $text_y);

sub quote {
	my $text = shift;
	for($text) {
		s/\\/\\\\/g;
		s/"/\\"/g;
		return qq("$text");
	}
}

my $id = quote($params{id});
my $desc = quote($params{description});

say "# dimensions-based-on = Sullins SBH11-PBPC-Dxx-ST-xx";
say "# numbering = " . ($dip_numbering ? "DIP" : "ribbon");
say "";
say qq!Element["" $desc "CONN?" $id @element_xys 1 $text_scale ""]!;
say "(";


# Attributes
if(@attributes) {
	my @a = map { quote($_) } @attributes;
	while(@a >= 2) {
		my $key = shift @a;
		my $value = shift @a;
		say qq!\tAttribute($key $value)!;
	}
	say "";
}

# Pins
{
	my $start_x = $pin_rect->left;
	my $inc_x = $pin_rect->width / ($columns - 1);
	my $start_y = $pin_rect->bottom;
	my $inc_y = -($pin_rect->height / ($rows - 1));

	my $pin = 0;

	my $pthick = mil_unit(60);
	my $pclear = mil_unit(30);
	my $pmask = mil_unit(66);
	my $pdrill = mil_unit(38);

	for my $column (0 .. $columns - 1) {
		my $x = $start_x + ($inc_x * $column);
		for my $row (0 .. $rows - 1) {
			my $y = $start_y + ($inc_y * $row);
			++$pin;
			my $pin_number;
			if($dip_numbering) {
				if($row == 0) {
					$pin_number = $column + 1;
				} else {
					$pin_number = ($rows * $columns) - $column;
				}
			} else {
				$pin_number = $pin;
			}
			my @flags = ('edge2');
			push @flags, 'square' if $pin == 1;
			my $flags = join(',', @flags);

			say qq@\tPin[${x}$unit ${y}$unit ${pthick}$unit ${pclear}$unit ${pmask}$unit ${pdrill}$unit "" "$pin_number" "$flags"]@;
		}
	}
}

say "";

sub outline {
	if(@_ >= 2) {
		my $x = shift;
		my $y = shift;
		my @current = ($x, $y);
		while(@_ >= 2) {
			$x = shift;
			$y = shift;
			my @next = ($x, $y);
			my @values = map { "$_$unit" } (@current,@next,$outline_thick);
			say "\tElementLine [@values]";
			@current = @next;
		}
	}
}

sub outline_and_close {
	if(@_ >= 2) {
		my $x = shift;
		my $y = shift;
		my @first = ($x, $y);
		if(@_ >= 2) {
			outline(@first, @_, @first);
		}
	}
}


sub rectangle_points {
	my $rect = shift;
	my($left, $top, $right, $bottom) = $rect->get_sides;
	return (
		($left, $top),
		($right, $top),
		($right, $bottom),
		($left, $bottom),
	);
}

sub arch_points {
	my $rect = shift;
	my($left, $top, $right, $bottom) = $rect->get_sides;
	return (
		($left, $bottom),
		($left, $top),
		($right, $top),
		($right, $bottom),
	);
}


sub notched_rectangle_points {
	my $rect = shift;
	my $notch_rect = shift;
	my($left, $top, $right, $bottom) = $rect->get_sides;
	my($notch_left, undef, $notch_right, undef) = $notch_rect->get_sides;
	return (
		($notch_left, $bottom),
		($left, $bottom),
		($left, $top),
		($right, $top),
		($right, $bottom),
		($notch_right, $bottom),
	);
}


sub outline_rectangle {
	my($left, $top, $right, $bottom) = @_;
	my @a = ($left,$top);
	my @b = ($right,$top);
	my @c = ($right,$bottom);
	my @d = ($left,$bottom);
	outline_and_close(@a,@b,@c,@d);
}


outline_and_close(rectangle_points($outer_rect));
say "";


outline(arch_points($notch_rect));
say "";
outline(notched_rectangle_points($bevel_rect, $notch_rect));
say "";
outline(notched_rectangle_points($inner_rect, $notch_rect));
say "";

{
	my @bp = rectangle_points($bevel_rect);
	my @ip = rectangle_points($inner_rect);

	while(@bp >= 2) {
		my @bevel_point = (shift(@bp), shift(@bp));
		my @inner_point = (shift(@ip), shift(@ip));
		outline(@bevel_point, @inner_point);
	}
}



say ")";
