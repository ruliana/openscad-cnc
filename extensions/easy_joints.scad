use <../extensions/easy_movement.scad>
use <../extensions/easy_vector.scad>
use <../extensions/easy_debug.scad>
use <../extensions/renamed_commands.scad>

module puzzle_joint_male(width,
                         depth,
                         joint_depth = -1,
                         joint_width_top = -1,
                         joint_width_bottom = -1,
                         round_top = -1,
                         round_bottom = -1) {

  default_ratio = 1.618; // Golden ratio, but it could be anything

  d = joint_depth < 0 ? width / default_ratio : joint_depth;

  bottom_margin = depth - d;
  width_top = joint_width_top < 0
    ? width / default_ratio
    : joint_width_top;

  width_bottom = joint_width_bottom < 0
    ? width_top / (default_ratio * default_ratio)
    : joint_width_bottom;

  rtop = round_top < 0 ? 1/2 * width_top : round_top;
  rbottom = round_bottom < 0 ? rtop : round_bottom;

  points = [[0, 0, 0],
            [0, bottom_margin, 0],
            [1/2 * (width - width_bottom), bottom_margin, rbottom],
            [1/2 * (width - width_top), depth, rtop],
            [1/2 * (width + width_top), depth, rtop],
            [1/2 * (width + width_bottom), bottom_margin, rbottom],
            [width, bottom_margin, 0],
            [width, 0, 0]];

  polyround(points);
}

module puzzle_joint_female(width,
                           depth,
                           joint_depth = -1,
                           joint_width_top = -1,
                           joint_width_bottom = -1,
                           round_top = -1,
                           round_bottom = -1) {

  default_ratio = 1.618; // Golden ratio, but it could be anything
  d = joint_depth < 0 ? width / default_ratio : joint_depth;

  difference() {
    square([width, depth]);
    translate([width, 2 * depth - d, 0])
    rotate([0, 0, 180])
    puzzle_joint_male(width,
                      depth,
                      joint_depth,
                      joint_width_top,
                      joint_width_bottom,
                      round_top,
                      round_bottom);
  }
}

module puzzle_joint(width,
                    depth,
                    height,
                    joint_width = -1) {

  extrude(0.5 * height)
    puzzle_joint_male(width,
                      depth,
                      joint_depth = 0.5 * depth,
                      joint_width_top = joint_width);

  up(0.5 * height)
    extrude(0.5 * height)
      puzzle_joint_female(width,
                          0.5 * depth,
                          joint_depth = 0.5 * depth,
                          joint_width_top = joint_width);
}
