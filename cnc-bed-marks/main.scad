use <../extensions/mirror_translate.scad>

// I tried to carve it with a sphere (which would be easier), but Kiri:Moto
// didn't like it. So I switched to this cut and Kiri:Motot trace, which also
// didn't work until I separated all the lines.
//
// It becomes overly complex, but it worked.

$fn = 50;
radius = 1/2 * 1/8 * 25.4;

size = 500;

module carver_x() {
  rotate([45, 0, 0])
  linear_extrude(sin(45) * radius * 2, center=true)
  square(sin(45) * radius * 2, center=true);
}

module carver_y() {
  rotate([0, 0, 90]) carver_x();
}

module ruler_x(width) {
  hull() union() {
    translate([width / 2, 0, 0]) carver_x();
    translate([2, 0, 0]) carver_x();
  }
  hull() union() {
    translate([-width / 2, 0, 0]) carver_x();
    translate([-2, 0, 0]) carver_x();
  }
}

module ruler_y(width) {
  hull() union() {
    translate([0, width / 2, 0]) carver_y();
    translate([0, 2, 0]) carver_y();
  }
  hull() union() {
    translate([0, -width / 2, 0]) carver_y();
    translate([0, -2, 0]) carver_y();
  }
}

difference() {
  translate([0, 0, -5]) cube([size + 10, size + 10, 10], center=true);

  ruler_x(size);
  mirror_translate([0, size / 2, 0]) ruler_x(size / 8);
  mirror_translate([0, size / 4, 0]) ruler_x(size / 4);

  ruler_y(size);
  mirror_translate([size / 2, 0, 0]) ruler_y(size / 8);
  mirror_translate([size / 4, 0, 0]) ruler_y(size / 4);
}
