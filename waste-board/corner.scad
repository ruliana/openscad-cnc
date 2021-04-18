use <../extensions/easy_movement.scad>
use <../extensions/easy_pocket.scad>

$fn = 30;

width = 120;
depth = 120;
height = 4.5;

gap = 30;

linear_extrude(height) {
  difference() {
    square([width, depth]);
    bw(gap) rg(gap) pocket(width, depth);
  }
}
