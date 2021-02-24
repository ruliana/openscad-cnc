// DEPRECATED: Use "pocket.scad"

// And extruded rectangle with dog bones at their end
module dog_bone(dimensions, bit_diameter=1, center=false) {
  module hole() { cylinder(dimensions.z, d=bit_diameter, center=center, $fn=50); }
  inset = sqrt(2 * pow(bit_diameter / 2, 2)) / 2;
  x = dimensions.x / 2 - inset;
  y = dimensions.y / 2 - inset;
  cube(dimensions, center=center);
  translate([-x, -y, 0]) hole();
  translate([-x, y, 0]) hole();
  translate([x, y, 0]) hole();
  translate([x, -y, 0]) hole();
}

dog_bone([10, 20, 5], 2, center=true);
