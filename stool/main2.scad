use <../extensions/easy_debug.scad>
use <../extensions/easy_vector.scad>
use <../extensions/easy_pocket.scad>
use <../extensions/Round-Anything/polyround.scad>

/* [Width] */
seat_width = 460; // [100:5:800]
leg_width = 460; // [100:5:800]

/* [Height] */
stool_height = 420; // [190:5:750]

/* [Depth] */
seat_depth = 390; // [100:5:800]
leg_top_depth = 320; // [100:5:800]
leg_base_depth = 360; // [100:5:800]

/* [Design] */
leg_thickness = 60; //[30:5:160]
corner_radius = 30; //[0:5:100]

/* [Hidden] */
$fn = 32;
origin = [0, 0];

/* [Construction Parameters] */
material_thickness = 19.5;
bit_diameter = 3.175;
bit_radius = bit_diameter / 2;

leg_height = [0, stool_height - material_thickness / 2];

function rpoint(vec, radius=0) = is_radii_point(vec) ? vec : [vec.x, vec.y, radius];

function rpoints(vecs, radius=0) = [for (vec = vecs) rpoint(vec, radius)];

// Key points (mostlyl the leg, as it's the accent here)
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

// Ignore the dowel and restrictions if the leg is too thin
enough_dowel_thickness = leg_thickness > 2.5 * material_thickness;

function leg_to_seat_dowel_points() =
  let(
      gap_x = [material_thickness / 2, 0],
      gap_y = [0, material_thickness / 2])
    [leg_top_corner_int + gap_x,
     leg_top_corner_ext - gap_x,
     leg_top_corner_ext - gap_x + gap_y,
     leg_top_corner_int + gap_x + gap_y];


module leg() {
  // ==========
  // Components
  // ==========
  module leg_structure() {
    points = [origin,
              rpoint(base_line_ext[1], corner_radius),
              leg_top_corner_ext,
              leg_top_corner_int,
              rpoint(bottom_elbow_int, corner_radius / 3),
              base_line_int[0]];

    polygon(polyRound(rpoints(points), 32));
  }

  module leg_to_seat_dowel() {
    if (enough_dowel_thickness)
      polygon(leg_to_seat_dowel_points());
  }

  module leg_pocket(extra_height=false) {
    width = material_thickness;
    height = extra_height
      ? leg_thickness / 2 + extra_height
      : leg_thickness / 2;
    pocket(width, height, fillet=u_shaped_south(), snap_point=north());
  }

  module leg_outline() {
    union() {
      leg_structure();
      leg_to_seat_dowel();
    }
  }

  function top_dowel_snap_point() =
    let(
        limit_ext = enough_dowel_thickness
                    ? leg_top_corner_ext - [material_thickness, -material_thickness / 2]
                    : leg_top_corner_ext - [material_thickness / 2, - material_thickness / 2],
        limit_int = enough_dowel_thickness
                    ? leg_top_corner_int + [material_thickness, material_thickness / 2]
                    : leg_top_corner_int + [material_thickness / 2, material_thickness / 2],
        top_dowel = parallel(leg_top_line, material_thickness / 2),
        top_dowel_mid = crossing(top_dowel, lateral_line_mid),
        pure_vertex = lateral_line_mid[1] - lateral_line_mid[0],
        dist = leg_thickness * pure_vertex.x / pure_vertex.y,
        snap_point = top_dowel_mid - [dist, 0])
    snap_point.x > limit_ext.x ? limit_ext
    : snap_point.x < limit_int.x ? limit_int
    : snap_point;

  // ==========
  // Assemble
  // ==========
  module half_leg() {
    difference() {
      leg_outline();
      // Top dowels
      snap(top_dowel_snap_point())
        leg_pocket(extra_height=material_thickness / 2);
      // Base dowel
      snap(base_line_int[0])
        leg_pocket();
    }
  }

  rotate([90, 0, 90])
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
    dowel_points = leg_to_seat_dowel_points();
    height = (norm(dowel_points[1] - dowel_points[0]));
    distance_from_mid = leg_top_corner_int.x + material_thickness / 2;

    /* Extrude and add a bit of material for a cleaner cut */
    translate([0, 0, -0.1])
      linear_extrude(material_thickness / 2 + 0.1) {

        // Top dowels
        translate([0, mid_depth.y + distance_from_mid])
            leg_positioning(base_guide, leg_width / 2)
              pocket(material_thickness, height, snap_point=sw());

        // Bottom dowels
        translate([0, mid_depth.y - distance_from_mid])
          leg_positioning(base_guide, leg_width / 2)
            pocket(material_thickness, height, snap_point=nw());
      }
  }

  module seat_structure() {
    points = [origin,
              bottom_corner_ext,
              top_corner_ext,
              top_corner_int];

    linear_extrude(material_thickness)
      polygon(polyRound(rpoints(points, corner_radius), 32));
  }

  translate([0, -seat_depth / 2, stool_height - material_thickness])
    difference() {
      seat_structure();
      pockets();
    }
}

module leg_positioning(line, distance) {
  center = mid(line);
  right_line = [center, line[1]];
  left_line = [center, line[0]];

  left_anchor = in_line(left_line, distance, restrict=true);
  right_anchor = in_line(right_line, distance, restrict=true);

  translate(left_anchor)
    children();

  translate(right_anchor)
    mirror([1, 0, 0]) children();
}

// ==========
// Assemble
// ==========
echo("========");
base_guide = [origin, [seat_width, 0]];
leg_positioning(base_guide, leg_width / 2) leg();
seat();