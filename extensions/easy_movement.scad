// Backward (+y axis)
module bw(distance) {
  translate([0, distance, 0]) children();
}

// Forward (-y axis)
module fw(distance) {
  bw(-distance) children();
}

// Right (+x axis)
module rg(distance) {
  translate([distance, 0, 0]) children();
}

// Left (-x axis)
module lf(distance) {
  rg(-distance) children();
}

// Up (+z axis)
module up(distance) {
  translate([0, 0, distance]) children();
}

// Down (-z axis)
module dn(distance) {
  up(-distance) children();
}

// Centered square
module sqr(width, depth) {
  square([width, depth], center=true);
}
