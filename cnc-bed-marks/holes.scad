use <../extensions/easy_movement.scad>
use <../extensions/renamed_commands.scad>

width = 700;
depth = 750;
thickness = 12;

hole_diameter = 20;
hole_spacing = 40;

$fn = 64;

module hole() {
  circle(d = hole_diameter + 0.1);
}

module bed() {
  spacing = hole_spacing + 0.5 * hole_diameter;
  initial_x = hole_spacing + 0.5 * hole_diameter;
  initial_y = hole_spacing + 0.5 * hole_diameter;
  extrude(thickness)
    difference() {
      square([width, depth]);
      for (x = [0:spacing:(width - 2 * spacing)]) {
        for (y = [0:spacing:(depth - 2 * spacing)]) {
          translate([initial_x + x, initial_y + y])
            hole();
        }
      }
    }
}

module pin() {
  thickness = 12.5;
  extrude(thickness) {
    circle(d = hole_diameter);
  }
}

module clamp() {
  thickness = 12.5;
  size = 60;
  difference() {
    extrude(thickness) {
      hull() {
        circle(d = size);
        rg(0.5 * size) circle(d = 40);
      }
      hull() {
        rg(0.5 * size) circle(d = 40);
        rg(80) circle(d = 20);
      }
    }
  }
}

*bed();
clamp();
*pin();
