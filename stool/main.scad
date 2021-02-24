use <../extensions/easy_movement.scad>
use <../extensions/mirror_translate.scad>
use <../extensions/polyline.scad>

$fn = 64;

model_height = 400;

seat_width = 500;
seat_depth = 430;

feet_depth = 485;

leg_thickness = 60;
leg_inward = 80;

inward = 120;

thickness = 19.5;

slack = 0.05;

full_height = model_height - thickness;
upper_dowel_depth = 1/2 * seat_depth - inward;

support_width = thickness;
support_height = 1/2 * leg_thickness;

top_support_pos = [upper_dowel_depth, full_height, 0];
mid_support_pos = [upper_dowel_depth + 1/2 * (1/2 * feet_depth - upper_dowel_depth) + 1/2 * thickness,
                   1/2 * full_height,
                   0];

module inner_round_corner(radius) {
  offset(r = -radius)
  offset(r = radius)
    children();
}

module outer_round_corner(radius) {
  offset(r = radius)
  offset(r = -radius)
    children();
}

module support_hole() {
  fw(1/2 * support_height)
    sqr(support_width + 2 * slack, support_height + 2 * slack);
}

module half_leg() {
  module top_dowel() {
    bw(full_height- 1/4 * thickness)
      rg(1/2 * seat_depth - inward)
        sqr(leg_thickness - 1/3 * leg_thickness, 1/2 * thickness);
  }

  module outline() {
    leg_outline = [
      [0, 1/2 * leg_thickness],
      [1/2 * feet_depth, 1/2 * leg_thickness],
      [upper_dowel_depth, full_height - 1/2 * thickness],
    ];

    difference() {
      inner_round_corner(1/2 * leg_thickness)
        polyline(leg_outline, width=leg_thickness);
      // Cut the rounded top
      bw(1/2 * leg_thickness + full_height - 1/2 * thickness + 1) sqr(9999, leg_thickness);
    }

    top_dowel();
  }

  // Outline
  difference() {
    outline();
    // Holes
    translate(top_support_pos) support_hole();
    translate(mid_support_pos) support_hole();
  }
}

module leg() {
  linear_extrude(thickness, center=true) {
    half_leg();
    mirror([1, 0, 0]) half_leg();
  }
}

module support() {
  width = seat_width;
  height = 1/2 * leg_thickness;

  difference() {
    // Bar
    bw(1/2 * height)
      cube([seat_width - leg_inward, height, thickness], center=true);

    // Dowel
    mirror_translate([1/2 * width - 1/2 * thickness - leg_inward, 0, 0])
      cube([thickness + 2 * slack, height + 2 * slack, thickness + 2 * slack], center=true);
  }
}

module seat() {
  linear_extrude(thickness)
   outer_round_corner(leg_thickness)
     sqr(seat_width, seat_depth);
}

module assembled() {
  module top_support() {
    translate(top_support_pos)
      rotate([90, 90, 90])
        fw(3/2 * support_height)
          support();
  }

  module top_supports() {
    top_support();
    mirror([1, 0, 0]) top_support();
  }

  module mid_support() {
    translate(mid_support_pos)
      rotate([90, 90, 90])
        fw(3/2 * support_height)
          support();
  }

  module mid_supports() {
    mid_support();
    mirror([1, 0, 0]) mid_support();
  }

  module legs() {
    mirror_translate([1/2 * seat_width - 1/2 * thickness - leg_inward, 0, 0])
      rotate([90, 0, 90])
      leg();
  }

  %up(full_height - 1/2 * thickness) seat();
  %legs();
  rotate([90, 0, 90]) top_supports();
  rotate([90, 0, 90]) mid_supports();
}

assembled();

*leg();
*support();
