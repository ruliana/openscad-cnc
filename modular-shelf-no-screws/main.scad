use <../extensions/easy_movement.scad>
use <../extensions/easy_vector.scad>
use <../extensions/renamed_commands.scad>
use <../extensions/easy_pocket.scad>
use <../extensions/easy_debug.scad>

/* [Exhibition] */
show = "assembled"; // [assembled:Assembled]
exploding_distance = 0; // [0:20:200]

/* [Dimensions] */
height = 760;
width = 200;
depth = 200;

/* [Options] */
feet = true;
supports = true;

/* [Shelves] */
number_of_shelves = 3; // [2:1:10]
top_shelf_distance = 0; // [0:10:500]
bottom_shelf_distance = 0; // [0:10:500]

/* [Construction] */
thickness = 12.0;
round_radius = 10;

/* bit_diameter = 6.35; */

/* [Derivate dimensions] */
w = width - 2 * thickness;
d = depth - 2 * thickness;

module side_panel() {
    extrude(thickness) polyround([
        [0, 0, 0],  
        [width, 0, 0], 
        [width, height, round_radius], 
        [0, height, round_radius]]);
}

side_panel();

