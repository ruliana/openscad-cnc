use <../extensions/easy_movement.scad>
use <../extensions/easy_vector.scad>
use <../extensions/renamed_commands.scad>
use <../extensions/easy_debug.scad>

$fn = 256;
show = "assembled"; // [assembled:Assembled, base:Base, stem:Stem]

material_thickness = 19;

 /* [Dimensions] */
holder_height = 300;
holder_width = 150;
holder_depth = 150;

/* [Style] */
frame_thickness = 19;
stem_displacement = 0;
stem_width = 100;

module base() {
  thickness = material_thickness;
  radius = holder_width;

  difference() {
    extrude(thickness)
      circle(d=holder_width);
    twin_stems();
  }
}

module stem_shape(width, height, thickness) {

  base_width = 0.4;

  middle_width = -0.4;
  middle_pos = 0.7;
  middle_curve = 600;

  points = [[base_width * width, 0.25 * material_thickness, 0],
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
    stem_shape(stem_width, height, frame_thickness);
}

module twin_stems() {
  lf(material_thickness) stem();
  mirror([0, 1, 0]) rg(material_thickness) stem();
}



if (show == "assembled") {
  rotate([0, 0, 90]) {
    base();
    twin_stems();
  }
} else if (show == "base") {
  base();
} else if (show == "stem") {
  fw(0.25 * material_thickness)
    up(0.5 * material_thickness)
      rotate([0, -90, -90])
        stem();
}
