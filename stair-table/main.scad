use <../extensions/mirror_translate.scad>
use <../extensions/rounded_square.scad>
use <../extensions/rounded_cube.scad>

$fn = 100;
INCH = 25.4;
bit_diameter = 1/4 * INCH;

thickness = 22;
width = 300;
depth = 300;
rounded_corner_radius = thickness;
border_distance = 10;

fence_height = thickness;
fence_thickness = thickness / 2;
gap_depth = 187;
gap_height = 13;

module base_slab() {
  rounded_cube([width, depth, thickness], rounded_corner_radius, center=true);
}

module base_gap() {
 translate([0, -depth / 2 + gap_depth / 2 + border_distance, -thickness + gap_height])
   cube([width + 1, gap_depth, thickness], center= true);
}

module base () {
  difference() {
    base_slab();
    base_gap();
  }
}

module fence() {
  linear_extrude(fence_height, center=true) {
    difference() {
      rounded_square([width, depth], rounded_corner_radius, center=true);
      offset(-fence_thickness) rounded_square([width, depth], rounded_corner_radius, center=true);
      translate([fence_thickness, -depth / 2]) square([width, thickness * 2], center=true);
      translate([width / 2, -fence_thickness]) square([thickness * 2, depth], center=true);
    }
  }
}

module assembled() {
  base();
  translate([0, 0, thickness]) fence();
}

module flat_pack() {
  rotate([180, 0, 0]) base();
  translate([-(fence_thickness + 1.8 * bit_diameter), fence_thickness + 1.8 * bit_diameter, 0]) fence();
}

assembled();
!flat_pack();