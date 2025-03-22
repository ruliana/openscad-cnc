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
width = 400;
depth = 250;

/* [Options] */
feet = true;
supports = true;

/* [Shelves] */
number_of_shelves = 4; // [2:1:10]
top_shelf_distance = 50; // [0:10:2000]
bottom_shelf_distance = 50; // [0:10:2000]
pockets_per_shelf = 3; // [1:1:10]

/* [Construction] */
thickness = 12.0;
round_radius = 10;
insert_round_radius = 10;
/* bit_diameter = 6.35; */

/* [Derivate dimensions] */
width_inner = width - 2 * thickness;
depth_inner = depth - 2 * thickness;

shelf_inner_height = height - bottom_shelf_distance - top_shelf_distance - thickness;
shelf_inner_spacing = shelf_inner_height / (number_of_shelves - 1);

pocket_width = depth / (pockets_per_shelf * 2);
insert_width = pocket_width;
insert_depth = 3 * thickness;
insert_gap_depth = thickness;

module pocket_cut(w, h) {
    translate([0, 0, 0.5 * thickness])
        extrude(2 * thickness, center=true)
            pocket(w, h);
}

module shelf_pockets() {
    for (i = [0:pockets_per_shelf - 1]) {
        spacing = 0.5 * pocket_width + pocket_width * i * 2;
        translate([spacing, 0, 0])
            pocket_cut(pocket_width, thickness);
    }
}

module side_panel_pockets() {

    // Bottom shelf
    translate([0, bottom_shelf_distance, 0])
        shelf_pockets(); 

    // Middle shelves
    for (i = [1:number_of_shelves - 2]) {
        spacing = bottom_shelf_distance + i * shelf_inner_spacing;
        translate([0, spacing, 0])
            shelf_pockets();
    }

    // Top shelf 
    translate([0, height - top_shelf_distance - thickness, 0])
        shelf_pockets();
}

module side_panel() {
    extrude(thickness) polyround([
        [0, 0, 0],  
        [depth, 0, 0], 
        [depth, height, round_radius], 
        [0, height, round_radius]]);
}

module side_panel_with_pockets() {
    difference() {
        side_panel();
        side_panel_pockets();
    }
}

module shelf() {
    cube([width_inner, depth, thickness]);
}

// The part that will be inserted in the side panel pockets
// It needs extra space to fit the pegs that will hold the shelf
module shelf_pocket_insert() {
    difference() {
        extrude(thickness)
            polyround([
                [0, 0, 0],
                [insert_width, 0, 0],
                [insert_width, insert_depth, insert_round_radius],
                [0, insert_depth, insert_round_radius]]);

        translate([insert_width / 2 - thickness / 2, thickness, 0])
            pocket_cut(thickness, insert_gap_depth);
    }
}

module shelf_with_insert() {
    union() {
        shelf();

        for (i = [0:pockets_per_shelf - 1]) {
            spacing = 0.5 * pocket_width + pocket_width * i * 2;
            translate([0, spacing, 0])
                rotate([0, 0, 90])
                    shelf_pocket_insert();
        }
        
        for (i = [0:pockets_per_shelf - 1]) {
            spacing = 0.5 * pocket_width + pocket_width * i * 2;
            translate([width_inner, pocket_width + spacing, 0])
                rotate([0, 0, -90])
                    shelf_pocket_insert();
        }
    }
}

if (show == "assembled") {
    // *** Side panels ***
    rotate([90, 0, 90])
        side_panel_with_pockets();

    translate([width - thickness, 0, 0])
        rotate([90, 0, 90])
            side_panel_with_pockets();

    // *** Shelves ***
       
    // Bottom shelf
    translate([thickness, 0, bottom_shelf_distance])
        shelf_with_insert();

    // Middle shelves
    for (i = [1:number_of_shelves - 2]) {
        spacing = bottom_shelf_distance + i * shelf_inner_spacing;
        translate([thickness, 0, spacing])
            shelf_with_insert();
    }

    // Top shelf 
    translate([thickness, 0, height - top_shelf_distance - thickness])
        shelf_with_insert();
}
