use <../extensions/easy_movement.scad>
use <../extensions/easy_vector.scad>
use <../extensions/renamed_commands.scad>
use <../extensions/easy_pocket.scad>
use <../extensions/easy_debug.scad>

/* [Exhibition] */
show = "assembled"; // [assembled:Assembled]
exploding_distance = 0; // [0:20:200]

/* [Dimensions] */
height = 350;
width = 250;
depth = 250;

/* [Options] */
feet = true;
supports = true;
/* [Shelves] */
number_of_shelves = 3; // [2:1:10]
top_shelf_distance = 0; // [0:10:500]
bottom_shelf_distance = 0; // [0:10:500]

/* [Construction] */
thickness = 11.0;
screw_hole_radius = 4.0;
screw_hole_height = 3.6;
screw_horizontal_offset = 50;
/* bit_diameter = 6.35; */

/* [Derivate dimensions] */
w = width - 2 * thickness;
d = depth - 2 * thickness;

shelf_distance_bottom = 2 * thickness + bottom_shelf_distance;
shelf_distance_upper = height - 2 * thickness - top_shelf_distance;
shelf_distance_available = shelf_distance_upper - shelf_distance_bottom;
shelf_distance_gap = shelf_distance_available / (number_of_shelves - 1);

support_height = shelf_distance_gap - thickness;
support_width = 2 * thickness;

module screwhole() {
    cylinder(h=screw_hole_height, r1=0.2, r2=screw_hole_radius, center = true, $fn = 32);
}


module side() {
    screw_vertical_offset = thickness - screw_hole_height / 2 + 0.1;
    difference() {
        linear_extrude(thickness) square([depth, height]);
        for (i = [shelf_distance_bottom : shelf_distance_gap : shelf_distance_upper]) {
            screw_height = i + thickness / 2;
            translate([screw_horizontal_offset, screw_height, screw_vertical_offset]) screwhole();
            translate([depth - screw_horizontal_offset, screw_height, screw_vertical_offset]) screwhole();
        }
    }
}

module shelf() {
    translate([thickness, thickness])
        cube([d, w, thickness]);
    translate([0, thickness])
        cube([thickness, w, 2 * thickness]);
    translate([depth - thickness, thickness])
        cube([thickness, w, 2 * thickness]);
}

module shelfs() {
    for (i = [shelf_distance_bottom : shelf_distance_gap : shelf_distance_upper])
        translate([0, 0, i]) shelf();
}

module feet() {
    cube([depth, thickness, 4 * thickness]);
}

module support() {
    cube([support_width, thickness, support_height]);
}

module support4() {
    h = thickness;
    translate([thickness, thickness, h]) support();
    translate([thickness, width - 2 * thickness, h]) support();
    translate([depth - 3 * thickness, thickness, h]) support();
    translate([depth - 3 * thickness, width - 2 * thickness, h]) support(); 
}

module supports() {
    for (i = [shelf_distance_bottom : shelf_distance_gap : shelf_distance_upper - thickness])
        translate([0, 0, i]) support4();
}

/* Main assembly */
translate([0, 0, 2 * thickness]) {
    translate([0, thickness]) {
        rotate([90]) {
            side();
        }
    }

    translate([0, width - thickness]) {
        rotate([90]) {
            mirror([0, 0, 1]) side();
        }
    }

    shelfs();

    supports();
}

translate([0, thickness]) {
    feet();
}

translate([0, width - 2 * thickness]) {
    feet();
}


/* Cutting plan */
/* Number of parts and their dimensions */
echo("========== Cutting plan ==========");
echo(str("Side panel: ", 2, " x ", [depth, height, thickness]));
echo(str("Shelves: ", number_of_shelves, " x ", [d, w, thickness]));
echo(str("Supports: ", (number_of_shelves - 1) * 4, " x ", [support_width, support_height, thickness]));
echo(str("Feet: ", 2, " x ", [4 * thickness, depth, thickness]));
echo();
echo(str(""));
echo("==================================");