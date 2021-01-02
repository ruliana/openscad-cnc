// Square with rounded borders
//
// If the border radius is a single number, all borders will have the
// same radius. Optionally, it can be a list with a radius for each
// corner (starting from bottom left and counting clockwise).
//
// If any radius is zero, that corner will be sharp.
module rounded_square(dimensions, radius = 1, center=false) {
  r = is_list(radius) ? radius : [radius, radius, radius, radius];

  translation = center ? -dimensions / 2 : [0, 0];

  translate(translation) {
    hull() {
      if (r[0] > 0)
        translate([r[0], r[0]]) circle(r[0]);
      else
        square(1);

      if (r[1] > 0)
        translate([r[1], dimensions.y - r[1]]) circle(r[1]);
      else
        translate([0, dimensions.y - 1]) square(1);

      if (r[2] > 0)
        translate([dimensions.x - r[2], dimensions.y - r[2]]) circle(r[2]);
      else
        translate([dimensions.x - 1, dimensions.y - 1]) square(1);

      if (r[3] > 0)
        translate([dimensions.x - r[3], r[3]]) circle(r[3]);
      else
        translate([dimensions.x - 1, 0]) square(1);
    }
  }
}
