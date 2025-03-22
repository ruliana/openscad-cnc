/*
 * Sanding Box
 *
 * This is a simple sanding box to sand small wood pieces.
 * 
 * Instead of holes on top of the box it has long grooves around to suck the dust inside.
 * At the front there is a lip to catch dust and another groove to suck the dust inside.
 * Behind it there is a hole for the vacuum hose.
 */
use <../extensions/easy_movement.scad>
use <../extensions/easy_vector.scad>
use <../extensions/renamed_commands.scad>
use <../extensions/easy_pocket.scad>
use <../extensions/easy_debug.scad>

/* [Exhibition] */
show = "cutout1"; // [assembled:Assembled, cutout1:Cutout 1, cutout2:Cutout 2]
exploding_distance = 0; // [0:10:200]

/* [Dimensions] */
height = 80;
width = 600;
depth = 600;

/* [Options] */

/* [Construction] */
thickness = 13.0;
groove_number = 8;
groove_depth = 10;
groove_gap = 14;
front_lip_size = 36;
front_lip_gap = 1;
vacuum_hole_diameter = 45;
bit_diameter = 6.35;
cutout_gap = 2 * bit_diameter + 2 * thickness;

/* [Derivate dimensions] */
w = width - 2 * thickness;
d = depth - 2 * thickness;
groove_depth_final = min(groove_depth, bit_diameter);
groove_gap_final = min(groove_gap, thickness);
side_panel_height = height - 2 * thickness;

module groove(w) {
    translate([0, 0, -0.5 * thickness])
        extrude(2 * thickness)
            polyround([
                [0, 0, bit_diameter],
                [w, 0, bit_diameter],
                [w, groove_depth_final, bit_diameter],
                [0, groove_depth_final, bit_diameter]
            ]);
}

module horizontal_groove(groove_number) {
    groove_w = (width - 2 * thickness - (groove_number - 1) * thickness) / groove_number;
    echo(str("horizontal groove_w: ", groove_w));
    for (i = [0:groove_number - 1])
        translate([i * (groove_w + thickness), 0, 0])
            groove(groove_w);
}   

module vertical_groove(groove_number) {
    groove_w = (depth - 7 * thickness - (groove_number - 1) * thickness) / groove_number;
    echo(str("vertical groove_w: ", groove_w));
    for (i = [0:groove_number - 1])
        translate([groove_depth_final, i * (groove_w + thickness) + 3 * thickness, 0])
            rotate([0, 0, 90])
                groove(groove_w);
}


module top() {
    groove_width_local = 0.5 * width - 3 * thickness;
    groove_depth_local = 0.5 * depth - 4 * thickness;

    difference() {
        extrude(thickness)
            square([width, depth]);
        // Bottom grooves
        translate([thickness, 2 *thickness, 0])
            horizontal_groove(groove_number);
        // Top grooves
        translate([thickness, depth - thickness - groove_depth_final, 0])
            horizontal_groove(groove_number);
        // Left grooves
        translate([thickness, thickness, 0])
            vertical_groove(groove_number);
        // Right grooves
        translate([width - thickness - groove_depth_final, thickness, 0])
            vertical_groove(groove_number);
    }
}

module bottom() {
    extrude(thickness)
        square([width, depth + front_lip_size]);
}

// Back panel with hole for the vacuum hose
module back_panel() {
    panel_w = depth;
    panel_h = side_panel_height;
    extrude(thickness)
        difference() {
            square([panel_w, panel_h + thickness]);
            translate([0.5 * panel_w, 0.5 * panel_h, 0])
                circle(d = vacuum_hole_diameter);
        }
}

module front_panel() {
    extrude(thickness)
        square([width - 2 * thickness, side_panel_height - front_lip_gap]);
}

module vertical_panel() {
    extrude(thickness)
        square([depth - 2 * thickness, side_panel_height]);
}

if (show == "assembled") {
    // Top
    translate([0, -thickness, height - thickness + 2 * exploding_distance])
        top();

    // Bottom
    translate([0, -front_lip_size, 0])
        bottom();

    // Front panel
    #translate([thickness, 2 * thickness - exploding_distance, thickness + front_lip_gap + exploding_distance])
        rotate([90, 0, 0])
            front_panel();

    // Back panel
    translate([0, depth + exploding_distance, thickness + exploding_distance])
        rotate([90, 0, 0])
            back_panel();

    // Left panel
    translate([-exploding_distance, thickness, thickness + exploding_distance])
        rotate([90, 0, 90])
            vertical_panel();

    // Right panel
    translate([width - thickness + exploding_distance, thickness, thickness + exploding_distance])
        rotate([90, 0, 90])
            vertical_panel();
}

if (show == "cutout1") {
    // Top
    projection()
        top();

    // Back panel  
    projection()
        translate([0, depth + cutout_gap, 0])  
                back_panel();

    // Side panel 1
    projection()
        translate([width + cutout_gap + height - 2 * thickness, 0, 0])  
            rotate([0, 0, 90])
                vertical_panel();
}

if (show == "cutout2") {
    // Bottom
    projection()
        translate([0, 0, 0])
            bottom();

    // Front panel
    projection()
        translate([0, depth + front_lip_size + cutout_gap, 0])
            front_panel();

    // Side panel 2
    projection()
        translate([width + cutout_gap + height - 2 * thickness, 0, 0])
            rotate([0, 0, 90])
                vertical_panel();
}
