#!/usr/bin/perl

# Copyright (c) 2010 David White, SprySoft Ltd, released under the MIT
#               license
# Copyright (c) 2016 Stephen Cristol, released under the MIT license

use 5.010;
use warnings;

use Scalar::Util qw/ looks_like_number /;

if ( @ARGV != 3 )
  {
  say "Usage:  $0 {num_cols} {col_width} {gutter_width}";
  exit;
  }

if ( grep { ! looks_like_number( $_ ) } @ARGV )
  {
  say "All input parameters must be numbers (you probably want them to be positive integers)";
  exit;
  }

my ( $num_cols, $col_width, $gutter_width ) = @ARGV;

my $margin_width = int( $gutter_width / 2 );
my $uneven_gutter = $gutter_width % 2;

my $margin_width_l = $margin_width;
my $margin_width_r = $margin_width;
$margin_width_l += 1
  if $uneven_gutter;
my $unit_width = $col_width + $gutter_width;
my $overall_width = $num_cols * $unit_width;

print <<"EOT";
/*
  Variable Grid System.
  Learn more ~ http://www.spry-soft.com/grids/
  Based on 960 Grid System - http://960.gs/

  Licensed under GPL and MIT.
*/

/*
  Forces backgrounds to span full width,
  even if there is horizontal scrolling.
  Increase this if your layout is wider.

  Note: IE6 works fine without this fix.
*/

body { min-width: ${overall_width}px; }

/* Containers
----------------------------------------------------------------------------------------------------*/
.container_$num_cols {
  width:        ${overall_width}px;
  margin-left:  auto;
  margin-right: auto;
}

/* Grid >> Global
----------------------------------------------------------------------------------------------------*/

EOT

my $grid_str = join ",\n", map { ".grid_$_" } 1 .. $num_cols;
$grid_str .= <<"EOT";
 {
  display:      inline;
  float:        left;
  position:     relative;
  margin-left:  ${margin_width_l}px;
  margin-right: ${margin_width_r}px;
}
EOT
print $grid_str, "\n\n\n";

my $push_pull_str = join ",\n", map { ".push_$_, .pull_$_" } 1 .. $num_cols;
$push_pull_str .= <<"EOT";
 {
  position: relative;
}
EOT
print $push_pull_str;


print <<"EOT";

/* Grid >> Children (Alpha ~ First, Omega ~ Last)
----------------------------------------------------------------------------------------------------*/

.alpha { margin-left:  0; }
.omega { margin-right: 0; }

/* Grid >> $num_cols Columns
----------------------------------------------------------------------------------------------------*/

EOT

my $temp_width;   # Recyclable

my $container_str = '';
$temp_width = $col_width;
for my $i ( 1 .. $num_cols ) {
  $container_str .= ".container_$num_cols .grid_$i { width: ${temp_width}px; }\n";
  $temp_width += $unit_width;
}
print $container_str;

simple_spacer_header( 'Prefix Extra Space' );

$temp_width = 0;
my $px_map = { map { $_ => ( $temp_width += $unit_width ) } 1 .. $num_cols - 1 };

generate_classes( $num_cols - 1, $px_map, ".container_$num_cols .prefix_%-4d { padding-left:  %5dpx; }\n" );

simple_spacer_header( 'Suffix Extra Space' );

generate_classes( $num_cols - 1, $px_map, ".container_$num_cols .suffix_%-4d { padding-right: %5dpx; }\n" );

simple_spacer_header( 'Push Space' );

generate_classes( $num_cols - 1, $px_map, ".container_$num_cols .push_%-4d   { left:          %5dpx; }\n" );

simple_spacer_header( 'Pull Space' );

$temp_width = 0;
$px_map = { map { $_ => ( $temp_width -= $unit_width ) } 1 .. $num_cols - 1 };

generate_classes( $num_cols - 1, $px_map, ".container_$num_cols .pull_%-4d   { left:          %5dpx; }\n" );

print <<'EOT';

/* Clear Floated Elements
----------------------------------------------------------------------------------------------------*/

/* http://sonspring.com/journal/clearing-floats */

.clear {
  clear: both;
  display: block;
  overflow: hidden;
  visibility: hidden;
  width: 0;
  height: 0;
}

/* http://www.yuiblog.com/blog/2010/09/27/clearfix-reloaded-overflowhidden-demystified */

.clearfix:before,
.clearfix:after {
  content: '\0020';
  display: block;
  overflow: hidden;
  visibility: hidden;
  width: 0;
  height: 0;
}

.clearfix:after { clear: both; }

/*
  The following zoom:1 rule is specifically for IE6 + IE7.
  Move to separate stylesheet if invalid CSS is a problem.
*/

.clearfix { zoom: 1; }
EOT

exit;

sub generate_classes
  {
  my ( $max, $px_map, $format ) = @_;
  printf $format, $_, $px_map->{$_}
    for 1 .. $max;
  }

sub simple_spacer_header {
  my ( $text ) = @_;
  print <<"EOT";

/* $text >> $num_cols Columns
----------------------------------------------------------------------------------------------------*/

EOT
  return;
}

