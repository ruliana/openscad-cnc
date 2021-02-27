use <../extensions/easy_movement.scad>;
use <../extensions/mirror_translate.scad>;

// The model is a cube, so this is height, depth, and width.
model_size = 180;

// How "deep" is the leg. To make it square, use the same value as the thickness.
leg_thickness = 30;

// Material thickness.
thickness = 19.2;

// Jig for rounding corners with a router.
include_jigs = true;

// Gap between the pieces in flat pack.
gap = 20;

// Make slightly larger cuts to fit the pieces better.
slack = 0.01;

// How many segments on curves? Higher means more detailed curves. The smaller values are quite interesting to play with.
curve_segments = 64; // [4, 8, 16, 32, 64, 128, 256]
$fn = curve_segments;

// End bit diameter (3.175mm = 1/8in).
bit_diameter = 3.175;

module round_corner(radius) {
  offset(r = radius)
  offset(r = -radius)
    children();
}

module flat_outline() {
  round_corner(30)
    sqr(model_size, model_size);
}

module flat_piece() {
  module dogbone() {
    mirror_translate([0.5 * thickness - 0.5 * bit_diameter, 0, 0])
      circle(d=bit_diameter, $fn=30);
  }

  reduction_ratio = 1 - (leg_thickness / (model_size / 2));
  difference() {
    flat_outline();
    scale([reduction_ratio, reduction_ratio]) flat_outline();
    // Dogbones
    bw(0.5 * model_size - 0.5 * leg_thickness) dogbone();
    fw(0.5 * model_size - 0.5 * leg_thickness) dogbone();
    lf(0.5 * model_size - 0.5 * leg_thickness) rotate([0, 0, 90]) dogbone();
    rg(0.5 * model_size - 0.5 * leg_thickness) rotate([0, 0, 90]) dogbone();
  }
}

module external_ring() {
  // Apply the slack on both side, so double it.
  local_slack = 2 * slack;
  linear_extrude(thickness) {
    difference() {
      flat_piece();
      sqr(model_size - leg_thickness + local_slack, thickness + local_slack);
      sqr(thickness + local_slack, model_size - leg_thickness + local_slack);
    }
  }
}

module half_ring(inner_or_outer) {
  linear_extrude(thickness) {
    // Apply the slack on both side, so double it.
    local_slack = 2 * slack;
    // Inner or outer ring means a small adjustment.
    move_dovetail = inner_or_outer == "inner" ?
                    0.5 * model_size :
                    0.5 * model_size - leg_thickness;
    difference() {
      flat_piece();
      mirror_translate([0.5 * model_size, 0])
        sqr(leg_thickness + local_slack, thickness + local_slack);
      bw(move_dovetail)
        sqr(thickness + local_slack, leg_thickness + local_slack);
      fw(0.25 * model_size)
        sqr(model_size, 0.5 * model_size);
    }
  }
}

module router_jig(pocket=true) {
  module dogbone() {
    dogbone_dist = 0.5 * bit_diameter / sqrt(2);
    rg(0.25 * model_size - 0.25 * leg_thickness)
      fw(0.25 * thickness) {
        // This extra space is for cut the dogbone clean
        // if we remove it, the cut will leave back a
        // weird facet.
        fw(0.5 * slack)
          sqr(0.5 * leg_thickness, 0.5 * thickness + slack);
        bw(0.25 * thickness - dogbone_dist)
          mirror_translate([0.25 * leg_thickness - dogbone_dist, 0, 0])
            circle(d=bit_diameter, $fn=30);
      }
  }

  lf(0.25 * model_size - 0.25 * leg_thickness)
    linear_extrude(thickness)
      difference() {
        intersection() {
          sqr(model_size - leg_thickness, thickness);
          rg(0.25 * model_size) sqr(0.5 * model_size, model_size);
        }
        if (pocket) dogbone();
    }
}


module flat_pack() {

  external_ring();

  rg(model_size + gap)
    rotate([0, 0, 90])
      half_ring("inner");

  rg(0.5 * model_size + 2 * gap + leg_thickness)
    fw(leg_thickness + gap)
      rotate([0, 0, -90])
        half_ring("inner");

  rg(1.5 * model_size + 3 * gap + leg_thickness)
    rotate([0, 0, 90])
      half_ring("outer");

  rg(1.0 * model_size + 4 * gap + 2 * leg_thickness)
    fw(leg_thickness + gap)
      rotate([0, 0, -90])
        half_ring("outer");

  if (include_jigs) {
    router_jig(pocket=false);
    bw(leg_thickness + slack) router_jig();
    fw(leg_thickness + slack) router_jig();
  }
}

module stock_area() {
  lf(0.5 * model_size)
    fw(0.5 * model_size + leg_thickness + gap) {
     flat_pack_width = model_size + 2 * (gap + (model_size - 2 * gap));
     flat_pack_depth = model_size + leg_thickness + gap;
     translate([0, -15, 0])
     text(str(flat_pack_width, "mm x ", flat_pack_depth, "mm"));
     square([flat_pack_width, flat_pack_depth]);
  }
}

flat_pack();
%stock_area();
