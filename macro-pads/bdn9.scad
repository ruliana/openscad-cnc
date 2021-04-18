use <../extensions/easy_movement.scad>
use <../extensions/easy_vector.scad>
use <../extensions/Round-Anything/polyround.scad>

$fn = 32;
show = "flat_pack"; // [flat_pack:Flat Pack, exploded:Exploded]
explosion_gap = 3;
flat_pack_gap = 5;

/* [Plate] */
plate_width = 73;
plate_depth = 73;
plate_thickness = 4.5;
plate_corner_radius = 5;

plate_padding_west = 10;
plate_padding_south = 11;

/* [Switch Holes] */
switch_width = 15.5;
switch_depth = 13.5;
switch_corner_radius = 1;

switch_gap_width = 4;
switch_gap_depth = 5.1;

/* [Screws] */
screw_diameter = 2;
screw_padding = 3;

support_screw_diameter = 3;
support_screw_padding = 25.5;

/* [Casing] */
casing_height = 9;
casing_thickness = 6;
casing_gap = 12;

function to_square(width, depth) =
  [[0, 0],
   [width, 0],
   [width, depth],
   [0, depth]];

module plate() {
  $fn = 16;
  plate = to_square(plate_width, plate_depth);
  polygon(round_corners(plate, plate_corner_radius));
}

module switch_holes() {
  $fn = 16;
  switch_hole = to_square(switch_width, switch_depth);
  for (i = [0:2]) {
    for (j = [0:2]) {
      h_spacing = switch_width + switch_gap_width;
      v_spacing = switch_depth + switch_gap_depth;
      separation = mov([i * h_spacing, j * v_spacing]);
      displacement = mov([plate_padding_west, plate_padding_south]);
      hole = apply(switch_hole, displacement * separation);
      polygon(round_corners(hole, switch_corner_radius));
    }
  }
}

module screw_holes() {
  screw_radius = 1/2 * screw_diameter;
  padding = screw_padding + screw_radius;
  fw(-padding) rg(padding)
    circle(d=screw_diameter);
  fw(-padding) rg(plate_width - padding)
    circle(d=screw_diameter);
  fw(-plate_depth + padding) rg(padding)
    circle(d=screw_diameter);
  fw(-plate_depth + padding) rg(plate_width - padding)
    circle(d=screw_diameter);
}

module support_screw_hole() {
  screw_radius = 1/2 * support_screw_diameter;
  padding = support_screw_padding + screw_radius;
  fw(-padding) rg(padding)
    circle(d=support_screw_diameter);
}

module switch_plate() {
  linear_extrude(plate_thickness) {
    difference() {
      plate();
      switch_holes();
      screw_holes();
    }
  }
}

module base_plate() {
  linear_extrude(plate_thickness) {
    difference() {
      plate();
      support_screw_hole();
      screw_holes();
    }
  }
}

module casing() {
  module contour() {
    gap = casing_gap;
    width = plate_width;
    depth = plate_depth;
    padding = casing_thickness;
    ext_round = plate_corner_radius;
    int_round = 1/2 * plate_corner_radius;
    points = [[0, 0, ext_round],
              [width, 0, ext_round],
              [width, depth, ext_round],
              [1/2 * (width + gap), depth, ext_round],
              [1/2 * (width + gap), depth - padding, ext_round],
              [width - padding, depth - padding, int_round],
              [width - padding, padding, int_round],
              [padding, padding, int_round],
              [padding, depth - padding, int_round],
              [1/2 * (width - gap), depth - padding, ext_round],
              [1/2 * (width - gap), depth, ext_round],
              [0, depth, ext_round]];
    polygon(polyRound(points, 32));
  }
  linear_extrude(casing_height) {
    difference() {
      contour();
      screw_holes();
    }
  }
}

module flat_pack() {
  switch_plate();
  fw(-1 * (plate_depth + flat_pack_gap)) base_plate();
  fw(-2 * (plate_depth + flat_pack_gap)) casing();
}

module exploded() {
  switch_plate_height = casing_height + plate_thickness + 2 * explosion_gap;
  casing_height = plate_thickness + explosion_gap;
  up(switch_plate_height) switch_plate();
  up(casing_height) casing();
  base_plate();
}

if (show == "exploded") {
  exploded();
} else if (show == "flat_pack") {
  flat_pack();
}
