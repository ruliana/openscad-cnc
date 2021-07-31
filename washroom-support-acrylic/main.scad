use <../extensions/renamed_commands.scad>
use <../extensions/easy_debug.scad>


bit_size = 25.4 / 4;
material_thickness = 3.25;

base_width = 80;
width = 315;
depth = 215;
round_sides = 60;
round_top = 120;

module scaffold() {
  multiplier = 25.4 / 4;
  points = [[0, 0],
            [-6, 0],
            [-13, 5],
            [-17.5, 9],
            [-19, 13],
            [-19.25, 14],
            [-19, 15],
            [-18.5, 18],
            [-17, 21],
            [-13, 24],
            [-11, 25.25],
            [-9, 26.5],
            [-8, 27],
            [-5, 28.25],
            [-2, 28.75],
            [-0, 28.75]];

  polygon(points * multiplier);
  mirror([1, 0, 0]) polygon(points * multiplier);
}

module holes() {
  $fn = 32;
  dist = 50;
  for (x = [-50:dist:50]) {
    for (y = [40:dist:160]) {
      translate([x, y, -0.1 * material_thickness])
        extrude(material_thickness * 1.2)
        circle(d=bit_size * 1.25);
    }
  }
}


module plate() {
  points = [[0, 0, 0],
            [0.5 * base_width, 0, 0],
            [0.5 * width, 0.43 * depth, round_sides],
            [0, depth, round_top],
            [-0.5 * width, 0.43 * depth, round_sides],
            [-0.5 * base_width, 0, 0]];

  extrude(material_thickness)
    offset(-5)
    polyround(points);
}

*scaffold();
difference() {
  plate();
  holes();
}
