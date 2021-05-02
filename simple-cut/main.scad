use <../extensions/easy_movement.scad>
use <../extensions/easy_vector.scad>
use <../extensions/easy_debug.scad>
use <../extensions/renamed_commands.scad>

$fn = 32;
show_guidelines = false;

/* [2x4 size] */
width = 85;
height = 33.5;
depth = 390;

/* [Joint size] */
joint_width_top = 50;
joint_width_bottom = 20;
joint_depth = 40;
joint_spacing = 20;

/* [Joint style] */
joint_round_top = 17;
joint_round_bottom = 10;
joint_bottom_margin = 1/2 * depth - 2 * joint_depth - joint_spacing;

if (show_guidelines) {
  show([[width, 0], [width, depth]]);
  show([[0, depth], [width, depth]]);
 }

module joint_plan(width, width_top, width_bottom, depth, round_top, round_bottom, bottom_margin) {
  points = [[0, -1 * bottom_margin, 0],
            [0, 0, 0],
            [1/2 * (width - width_bottom), 0, round_bottom],
            [1/2 * (width - width_top), depth, round_top],
            [1/2 * (width + width_top), depth, round_top],
            [1/2 * (width + width_bottom), 0, round_bottom],
            [width, 0, 0],
            [width, -1 * bottom_margin, 0]];

  polyround(points);
}

module joint_a(margin) {
  joint_plan(width,
             joint_width_top,
             joint_width_bottom,
             joint_depth,
             joint_round_top,
             joint_round_bottom,
             margin);
}

module joint_b(margin) {
  rg(width) bw(joint_depth) {
    rotate([0, 0, 180]) {
      difference() {
        square([width, joint_depth + margin]);
        joint_a(joint_bottom_margin);
      }
    }
  }
}

module joint_ab() {
  top_margin = joint_bottom_margin;
  bottom_margin = top_margin + joint_depth + joint_spacing;

  bw(bottom_margin)
    extrude(1/2 * height)
    joint_a(bottom_margin);

  up(1/2 * height) bw(top_margin)
    extrude(1/2 * height)
    joint_b(top_margin);
}

joint_ab();
mirror([0, 1, 0]) joint_ab();
