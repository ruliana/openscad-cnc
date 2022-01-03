use <../extensions/renamed_commands.scad>
use <../extensions/easy_movement.scad>
use <../extensions/easy_pocket.scad>

/* [Dimensions] */
width = 400;
height = 540;
depth = 150;

/* [Design] */
shelf_heights = [528, 300, 50];
fringe_height = 50;

/* [Construction] */
material_thickness = 12;
pocket_clearance = 0.1;
bit_diameter = 6.35;

/* [Hidden] */
$fn = 64;

module side_panel() {
  w = height;
  d = depth;
  h = material_thickness;

  module this_pocket() {
    pocket_height = material_thickness + pocket_clearance;
    pocket_width = d - 2 * material_thickness;
    translate([0,
               material_thickness,
               h / 2 - pocket_clearance])
      extrude(material_thickness)
        pocket(pocket_height, pocket_width,
               bit_diameter = bit_diameter,
               clearance = pocket_clearance);
  }

  difference () {
    cube([w, d, h]);
    for (i = shelf_heights) {
      translate([w - i, 0, 0])
        this_pocket();
    }
  }
}

module shelf() {
  w = width - material_thickness;
  d = depth - 2 * material_thickness;
  h = material_thickness;
  cube([w, d, h]);
}

module shelf_support() {
  w = width - 2 * material_thickness;
  d = fringe_height;
  h = material_thickness;
  cube([w, d, h]);
}

translate([0, 0, height])
  rotate([0, 90, 0])
    side_panel();

translate([width, 0, height])
  mirror([1, 0, 0])
    rotate([0, 90, 0])
      side_panel();

for (i = shelf_heights) {
  translate([material_thickness / 2,
             material_thickness,
             i - material_thickness])
    shelf();

  translate([material_thickness,
             material_thickness,
             i - fringe_height + material_thickness])
    rotate([90, 0, 0])
      shelf_support();

  translate([material_thickness,
             depth,
             i - fringe_height + material_thickness])
    rotate([90, 0, 0])
      shelf_support();
}

/* side_panel(); */
/* shelf(); */
/* shelf_support(); */
