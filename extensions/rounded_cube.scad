use <rounded_square.scad>

// Extrude version of rounded square
//
// It does not round in Z dimension. That's because my most
// common use is really an extruded rounded square than a
// fully rounded cube.
module rounded_cube(dimensions, radius = 1, center=false) {
  linear_extrude(dimensions.z, center=center)
    rounded_square(dimensions, radius, center=center);
}
