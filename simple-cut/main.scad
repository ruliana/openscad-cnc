use <../extensions/easy_movement.scad>

width = 89.5;
height = 49.5;
depth = 600;

module cutter() {
  translate([1/2 * width, height, - 1])
    cube([width, height, height + 2]);
}

module half_lap_1() {
  fw(1/2 * depth)
  rotate([0, -90, 0])
    difference() {
      cube([width, 1/2 * depth, height]);
      cutter();
    }
}

module half_lap() {
  half_lap_1();
  mirror([0, 1, 0]) half_lap_1();
}

for (i = [1:4])
  rg(i * height + i * 0.5) half_lap();
