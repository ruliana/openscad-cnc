use <../extensions/easy_movement.scad>
use <../extensions/easy_vector.scad>
use <../extensions/renamed_commands.scad>
use <../extensions/easy_debug.scad>

$fn = 256;
show = "exploded"; // [flat_pack:Flat Pack, exploded:Exploded]
explosion_gap = 3;
flat_pack_gap = 5;

material_thickness = 19;

 /* [Dimensions] */
holder_height = 300;
holder_width = 150;
holder_depth = 150;

/* [Style] */
frame_thickness = 19;
stem_displacement = 0;
stem_width = 100;
cap_radius = 70;
cap_angle = 135;
cap_tilt = 15;

module base() {
  thickness = material_thickness;
  radius = holder_width;

  difference() {
    extrude(thickness)
      circle(d=holder_width);
  }
}

/* module ellipsoid(width, height, thickness) { */
/*   radius = 0.5 * width; */
/*   stem_height = 0.5 * (height - 2 * radius); */

/*   module shell() { */
/*     hull() { */
/*       bw(stem_height) */
/*         circle(radius); */
/*       bw(-stem_height) */
/*         circle(radius); */
/*     } */
/*   } */

/*   module 2d_ellipsoid() { */
/*     difference() { */
/*       shell(); */
/*       offset(-thickness) shell(); */
/*     } */
/*   } */

/*   bw(0.5 * material_thickness) */
/*   up(stem_height + radius) */
/*   rotate([90, 0, 0]) */
/*   extrude(material_thickness) */
/*     2d_ellipsoid(); */
/* } */

module ellipsoid(width, height, thickness) {

  base_width = 0.4;

  middle_width = -0.4;
  middle_pos = 0.7;
  middle_curve = 600;

  points = [[base_width * width, 0, 0],
            [base_width * width, 1.15 * material_thickness, 0],
            [middle_width * width, middle_pos * height, middle_curve],
            [0, height, 6 * thickness],
            [0.55 * width, 0.95 * height, 6 * thickness],
            [0.9 * width, height, 3 * thickness]
            /* [(1.0 - middle_width) * width, middle_pos * height, middle_curve], */
            /* [(1.0 - base_width) * width, thickness, 0], */
            /* [(1.0 - base_width) * width, 0, 0], */
            ];

  bw(0.5 * material_thickness)
  lf(0.5 * width)
  rotate([90, 0, 0])
  extrude(material_thickness)
    beam(points, 0.5 * thickness, -0.5 * thickness);
}

module stem(height = holder_height) {
  rotate([0, 0, 90])
  fw(stem_displacement)
    ellipsoid(stem_width, height, frame_thickness);
}

module half_cap() {
  thickness = 1.5 * frame_thickness;
  radius = frame_thickness; // TODO replace it by "groove_depth"?

  module cap_contour() {
    rg(cap_radius - thickness)
      difference() {
        square([thickness, 2 * radius]);
        bw(radius) rg(thickness + 0.6 * radius)
          circle(radius);
    }
  }

  rotate_extrude(angle=cap_angle)
    cap_contour();
}

module right_half_cap() {
  half_cap();
}

module left_half_cap() {
  mirror([0, 0, 1])
    dn(frame_thickness)
      half_cap();
}

module cap() {
  up(holder_height - cap_radius)
  bw(material_thickness)
  rotate([0, -cap_tilt, 0])
  rotate([90, 0, 0]) {
    up(material_thickness) left_half_cap();
    right_half_cap();
  }
}

/* rotate([90, 0, 0]) */
/* show([[0, 0], [0, holder_height]]); */

%base();
*stem();
lf(material_thickness) stem();
mirror([0, 1, 0]) rg(material_thickness) stem();
*cap();
