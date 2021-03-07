use <../extensions/easy_debug.scad>
use <../extensions/easy_vector.scad>
use <../extensions/easy_rotate.scad>
use <../extensions/easy_pocket.scad>
use <../extensions/mirror_translate.scad>
use <../extensions/Round-Anything/polyround.scad>

view = "assembled"; // [assembled:Assembled, exploded:Exploded, seat:Seat, leg:Leg, base_support:Base Support, seat_support:Seat Support]
explosion_distance = 32;

/* [Width] */
seat_width = 460; // [100:5:800]
leg_width = 460; // [100:5:800]

/* Legs are never wider than the seat */
leg_width_restricted = min(leg_width, seat_width);

/* [Height] */
stool_height = 420; // [190:5:750]

/* [Depth] */
seat_depth = 390; // [100:5:800]
leg_top_depth = 320; // [100:5:800]
leg_base_depth = 360; // [100:5:800]

/* [Design] */
leg_thickness = 60; //[30:5:200]
seat_corner_radius = 30; //[0:5:300]
leg_corner_radius = 30; //[0:5:300]
support_overhang = 60; //[0:5:200]

/* [Hidden] */
$fn = 32;
origin = [0, 0];

/* [Construction Parameters] */
material_thickness = 19.5;
bit_diameter = 3.175;
bit_radius = bit_diameter / 2;
pocket_allowance = 0.01;


leg_height = [0, stool_height - material_thickness / 2];

function rpoint(vec, radius=0) = is_radii_point(vec) ? vec : [vec.x, vec.y, radius];

function rpoints(vecs, radius=0) = [for (vec = vecs) rpoint(vec, radius)];

// Key points (mostly the leg, as it's the accent here)
half_leg_base_depth = [leg_base_depth, 0] / 2;
half_leg_top_depth = [min(leg_top_depth, seat_depth), 0] / 2;
top_right_ext = leg_height + half_leg_top_depth;
stool_top_line = [leg_height, top_right_ext];
leg_top_line = parallel(stool_top_line, -material_thickness / 2);

base_line_ext = [origin, half_leg_base_depth];
base_line_int = parallel(base_line_ext, leg_thickness);
lateral_line_ext = [half_leg_base_depth, top_right_ext];
lateral_line_mid = parallel(lateral_line_ext, leg_thickness / 2);
lateral_line_int = parallel(lateral_line_ext, leg_thickness);

bottom_elbow_int = crossing(base_line_int, lateral_line_int);
leg_top_corner_int = crossing(leg_top_line, lateral_line_int);
leg_top_corner_ext = crossing(leg_top_line, lateral_line_ext);
base_guide = [origin, [seat_width, 0]];

function top_dowel_snap_point() =
  let(
      limit_ext = leg_top_corner_ext - [material_thickness / 2, -material_thickness / 2],
      limit_int = leg_top_corner_int + [material_thickness / 2, material_thickness / 2],
      top_dowel = parallel(leg_top_line, material_thickness / 2),
      top_dowel_mid = crossing(top_dowel, lateral_line_mid),
      pure_vertex = lateral_line_mid[1] - lateral_line_mid[0],
      dist = leg_thickness * pure_vertex.x / pure_vertex.y,
      snap_point = top_dowel_mid - [dist, 0])
  snap_point.x > limit_ext.x ? limit_ext
  : snap_point.x < limit_int.x ? limit_int
  : snap_point;

module leg() {
  // ==========
  // Components
  // ==========
  module leg_structure() {
    points = [origin,
              rpoint(base_line_ext[1], leg_corner_radius),
              leg_top_corner_ext,
              leg_top_corner_int,
              rpoint(bottom_elbow_int, leg_corner_radius / 3),
              base_line_int[0]];

    polygon(polyRound(rpoints(points), 32));
  }

  module leg_pocket(extra_height=false) {
    width = material_thickness;
    height = extra_height
      ? leg_thickness / 2 + extra_height
      : leg_thickness / 2;
    pocket(width, height, clearance=pocket_allowance, fillet=u_shaped_south(), snap_point=north());
  }

  // ==========
  // Assemble
  // ==========
  module half_leg() {
    difference() {
      leg_structure();
      // Top dowels
      snap(top_dowel_snap_point())
        leg_pocket(extra_height=material_thickness / 2);
      // Base dowel
      snap(base_line_int[0])
        leg_pocket();
    }
  }

  rotate(to_right())
     linear_extrude(material_thickness) {
       half_leg();
       mirror([1, 0, 0]) half_leg();
     }
}

module seat() {
  bottom_corner_ext = [seat_width, 0];
  top_corner_ext = [seat_width, seat_depth];
  top_corner_int = [0, seat_depth];
  mid_depth = mid([origin, top_corner_int]);

  module pockets() {
    /* Get pocket coordinates from leg */
    height = material_thickness;
    width = max(leg_thickness, material_thickness);
    distance_from_mid = top_dowel_snap_point().x - material_thickness / 2;

    /* Extrude and add a bit of material for a cleaner cut */
    translate([0, 0, -0.1])
      linear_extrude(material_thickness / 2 + 0.1) {

        // Top dowels
        translate([0, mid_depth.y + distance_from_mid])
            in_line_mirror(base_guide, leg_width_restricted / 2)
              pocket(width, height, clearance=pocket_allowance, snap_point=sw());

        // Bottom dowels
        translate([0, mid_depth.y - distance_from_mid])
          in_line_mirror(base_guide, leg_width_restricted / 2)
            pocket(width, height, snap_point=nw());
      }
  }

  module seat_structure() {
    points = [origin,
              bottom_corner_ext,
              top_corner_ext,
              top_corner_int];

    linear_extrude(material_thickness)
      polygon(polyRound(rpoints(points, seat_corner_radius), 32));
  }

  translate([0, -seat_depth / 2, stool_height - material_thickness])
    difference() {
      seat_structure();
      pockets();
    }
}

module support(top_peg=false) {
  extra_width = support_overhang * 2;
  width = min(leg_width_restricted + extra_width, seat_width);
  height = leg_thickness;
  depth = material_thickness;
  pocket_width = material_thickness;
  pocket_height = leg_thickness / 2;
  pocket_fillet = leg_width >= seat_width
    ? [false, false, [-1, 0], false]
    : u_shaped();

  peg_width = max(leg_thickness, material_thickness);

  rotate(to_front())
    translate([(seat_width - width) / 2, 0, -depth / 2])
      linear_extrude(depth)
        difference() {
          union() {
            square([width, height]);

            if (top_peg) {
              in_line_mirror([origin, [width, 0]], [leg_width_restricted / 2, leg_thickness]) {
                square([peg_width, material_thickness / 2]);
              }
            }
          }

          if (top_peg) {
            in_line_mirror([origin, [width, 0]], [leg_width_restricted / 2, leg_thickness]) {
              translate([peg_width + bit_radius * cos(45), bit_radius * sin(45), 0])
                circle(d=bit_diameter);
            }
          }

          in_line_mirror([origin, [width, 0]], leg_width_restricted / 2, restrict=true)
            pocket(pocket_width, pocket_height, clearance=pocket_allowance, fillet=pocket_fillet);
        }
}

module base_support() {
  support();
}

module seat_support() {
  // Support positioning
  translate([0, 0, top_dowel_snap_point().y - material_thickness / 2])
    mirror_translate([0, top_dowel_snap_point().x, 0])
      // Fix anchoring
      translate([0, 0, -leg_thickness])
        support(top_peg=true);
}

// ==========
// Assemble
// ==========

if (view == "assembled") {
  seat();
  base_support();
  seat_support();
  // Leg
  in_line_mirror(base_guide, leg_width_restricted / 2) leg();
} else if (view == "exploded") {
  translate([0, 0, 2 * explosion_distance]) seat();
  translate([0, 0, explosion_distance]) base_support();
  translate([0, 0, explosion_distance]) seat_support();
  // Leg
  in_line_mirror(base_guide, leg_width_restricted / 2 + explosion_distance) leg();
} else if (view == "seat") {
  rotate([180, 0, 0])
   translate([0, 0, -stool_height])
     seat();
} else if (view == "leg") {
  rotate([-90, -90, 0]) leg();
} else if (view == "base_support") {
  rotate([90, 0, 0])
    translate([0, material_thickness / 2, -leg_thickness])
      base_support();
} else if (view == "seat_support") {
  rotate([-90, 0, 0])
    translate([0, -material_thickness / 2, 0])
      support(top_peg=true);
}
