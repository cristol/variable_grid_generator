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

my ( $margin_width_l, $margin_width_r ) = compute_margins( $gutter_width );
my $unit_width = $col_width + $gutter_width;
my $overall_width = $num_cols * $unit_width;

print <<"EOT";
/*
  Variable Grid System
  Distributed under the MIT license.

  Based on 960 Grid System (http://960.gs/)
  More information at:
    https://github.com/cristol/variable_grid_generator
    https://github.com/sprysoft/variable_grid_generator

  This file was generated with the $0 command. Parameters were:
    Number of columns = $num_cols
    Width of columns  = $col_width
    Width of gutters  = $gutter_width
*/

/*
  Forces backgrounds to span full width,
  even if there is horizontal scrolling.
  Increase this if your layout is wider.

  Note: IE6 works fine without this fix.
*/
body { min-width: ${overall_width}px; }

/* The entire layout should be done inside the .container class */
.container_$num_cols {
  width:        ${overall_width}px;
  margin-left:  auto;
  margin-right: auto;
}

/* Use .alpha (first) & .omega (last) on grids nested in grids */
.alpha { margin-left:  0; }
.omega { margin-right: 0; }

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
print $grid_str, "\n";

my $push_pull_str = join ",\n", map { ".push_$_, .pull_$_" } 1 .. $num_cols;
$push_pull_str .= <<"EOT";
 {
  position: relative;
}
EOT
print $push_pull_str;

print <<"EOT";

/* Grid >> $num_cols Columns
----------------------------------------------------------------------------------------------------*/

EOT

# Recyclable variable
my $px_map = map_id_to_width( $num_cols, -$gutter_width, $unit_width );

class_selectors(
  $num_cols,
  $px_map,
  ".container_$num_cols .grid_%-4d   { width:         %5dpx; }\n",
  );

$px_map = map_id_to_width( $num_cols - 1, 0, $unit_width );

class_selectors(
  $num_cols - 1,
  $px_map,
  ".container_$num_cols .prefix_%-4d { padding-left:  %5dpx; }\n",
  );

class_selectors(
  $num_cols - 1,
  $px_map,
  ".container_$num_cols .suffix_%-4d { padding-right: %5dpx; }\n",
  );

class_selectors(
  $num_cols - 1,
  $px_map,
  ".container_$num_cols .push_%-4d   { left:          %5dpx; }\n",
  );

$px_map = map_id_to_width( $num_cols - 1, 0, -$unit_width );

class_selectors(
  $num_cols - 1,
  $px_map,
  ".container_$num_cols .pull_%-4d   { left:          %5dpx; }\n",
  );

print <<'EOT';
/* The .grid_* classes are all floated; use the .clear class to end rows */

/* http://sonspring.com/journal/clearing-floats */

.clear {
  clear:      both;
  display:    block;
  overflow:   hidden;
  visibility: hidden;
  width:      0;
  height:     0;
}

/* http://www.yuiblog.com/blog/2010/09/27/clearfix-reloaded-overflowhidden-demystified */

.clearfix:before,
.clearfix:after {
  content:    '\0020';
  display:    block;
  overflow:   hidden;
  visibility: hidden;
  width:      0;
  height:     0;
}

.clearfix:after { clear: both; }

/*
  The following zoom:1 rule is specifically for IE6 + IE7.
  Move to separate stylesheet if invalid CSS is a problem.
*/

.clearfix { zoom: 1; }
EOT

exit;

##  ====================================================================

sub compute_margins {
  my ( $gutter_width ) = @_;
  my $margin_width = int( $gutter_width / 2 );
  my $uneven_gutter = $gutter_width % 2;
  return $margin_width + $uneven_gutter, $margin_width;
}

sub map_id_to_width {
  my ( $max_id, $first_width, $increment ) = @_;
  my $width = $first_width;
  return { map { $_ => ( $width += $increment ) } 1 .. $max_id };
}

sub class_selectors
  {
  my ( $max, $px_map, $format ) = @_;
  printf $format, $_, $px_map->{$_}
    for 1 .. $max;
  print "\n";
  return;
  }

