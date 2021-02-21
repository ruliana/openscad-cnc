use <../extensions/easy_movement.scad>;
use <../extensions/mirror_translate.scad>;

// Width of the square part.
model_width = 160;

// Support height.
model_height = 0.5 * model_width;

// How "deep" is the leg. To make it square, use the same value as the thickness.
leg_thickness = 30;

// Material thickness.
thickness = 19.5;

// Pack of 4 in a square sheet.
4_pack = false;

// Jig for rounding corners with a router.
include_jigs = true;

// Gap between the pieces in flat pack.
gap = 10;

// Make slightly larger cuts to fit the pieces better.
slack = 0.01;

// How many segments on curves? Higher means more detailed curves. The smaller values are quite interesting to play with.
curve_segments = 64; // [4, 8, 16, 32, 64, 128, 256]
$fn = curve_segments;

// End bit diameter (3.175 = 1/8in).
bit_diameter = 3.175;

module round_corner(radius) {
  offset(r = radius)
  offset(r = -radius)
    children();
}

module flat_outline() {
  round_corner(30)
    sqr(model_width, model_height * 2);
}

module flat_piece() {
  module dogbone() {
    mirror_translate([0.5 * thickness - 0.5 * bit_diameter, 0, 0])
      circle(d=bit_diameter, $fn=30);
  }

  reduction_ratio_width = 1 - (leg_thickness / (model_width / 2));
  reduction_ratio_height = 1 - (leg_thickness / model_height);
  difference() {
    flat_outline();
    scale([reduction_ratio_width, reduction_ratio_height]) flat_outline();
    // Dogbones
    bw(model_height - 0.5 * leg_thickness) dogbone();
    fw(model_height - 0.5 * leg_thickness) dogbone();
    lf(0.5 * model_width - 0.5 * leg_thickness) rotate([0, 0, 90]) dogbone();
    rg(0.5 * model_width - 0.5 * leg_thickness) rotate([0, 0, 90]) dogbone();
  }
}

module external_ring() {
  // Apply the slack on both side, so double it.
  local_slack = 2 * slack;
  linear_extrude(thickness) {
    difference() {
      flat_piece();
      // Dogbones
      sqr(model_width - leg_thickness + local_slack, thickness + local_slack);
      sqr(thickness + local_slack, 2 * model_height - leg_thickness + local_slack);
    }
  }
}

module half_ring(inner_or_outer) {
  linear_extrude(thickness) {
    // Apply the slack on both side, so double it.
    local_slack = 2 * slack;
    // Inner or outer ring means a small adjustment.
    move_dovetail = inner_or_outer == "inner" ?
                    model_height :
                    model_height - leg_thickness;
    difference() {
      flat_piece();
      mirror_translate([0.5 * model_width, 0])
        sqr(leg_thickness + local_slack, thickness + local_slack);
      bw(move_dovetail)
        sqr(thickness + local_slack, leg_thickness + local_slack);
      fw(0.5 * model_height + 0.5 * thickness)
        sqr(model_width, model_height);
    }
    // HACK: Cover the dogbone in the corner
    mirror_translate([0.5 * model_width, 0])
      lf(0.75 * leg_thickness)
        fw(0.25 * thickness)
          sqr(0.5 * leg_thickness, 0.5 * thickness);
  }
}

module router_jig(pocket=true, double=false) {
  module dogbone() {
    dogbone_dist = 0.5 * bit_diameter / sqrt(2);
    rg(0.25 * model_width - 0.25 * leg_thickness)
      fw(0.25 * thickness) {
        // This extra space is for cut the dogbone clean
        // if we remove it, the cut will leave back a
        // weird facet.
        fw(0.25 * thickness + 0.5 * slack)
          sqr(0.5 * leg_thickness, thickness + slack);
        bw(0.25 * thickness - dogbone_dist)
          mirror_translate([0.25 * leg_thickness - dogbone_dist, 0, 0])
            circle(d=bit_diameter, $fn=30);
      }
  }

  depth = double ? 2 * thickness : thickness;
  lf(0.25 * model_width - 0.25 * leg_thickness)
    linear_extrude(thickness)
      difference() {
        intersection() {
          sqr(model_width - leg_thickness, depth);
          rg(0.25 * model_width) sqr(0.5 * model_width, model_width);
        }
        if (pocket) dogbone();
    }
}


module single_flat_pack(include_jigs=false) {

  external_ring();

  rg(model_height + 0.5 * model_width + gap)
    rotate([0, 0, 90])
      half_ring("inner");

  rg(2 * model_height + 0.5 * model_width + 2 * gap + 0.5 * thickness)
    rotate([0, 0, 90])
      half_ring("outer");

  if (include_jigs) {
    bw(leg_thickness + slack) router_jig(pocket=false);
    fw(thickness) router_jig(double=true);
  }
}

module 4x_flat_pack() {
  single_flat_pack(include_jigs);
  bw(2 * model_height + gap) single_flat_pack(include_jigs=false);
  bw(4 * model_height + 2 * gap) single_flat_pack(include_jigs=false);
  rg(2 * model_height + model_width + 3 * gap + thickness) rotate([0, 0, 90]) single_flat_pack(include_jigs=false);
}

module single_stock_area() {
  lf(0.5 * model_width)
    fw(model_height) {
     flat_pack_width = model_width + 2 * gap + 2 * model_height + thickness;
     flat_pack_depth = 2 * model_height;
     %square([flat_pack_width, flat_pack_depth]);
     fw(20) text(str(flat_pack_width, "mm x ", flat_pack_depth, "mm"));
  }
}

module 4x_stock_area() {
  lf(0.5 * model_width)
    fw(model_height) {
     flat_pack_width = 2 * model_width + 3 * gap + 2 * model_height + thickness;
     flat_pack_depth = 6 * model_height + 2 * gap;
     %square([flat_pack_width, flat_pack_depth]);
     fw(20) text(str(flat_pack_width, "mm x ", flat_pack_depth, "mm"));
  }
}

if (4_pack) {
  4x_flat_pack();
  4x_stock_area();
} else {
  single_flat_pack();
  single_stock_area();
}
