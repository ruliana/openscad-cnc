use <../extensions/easy_movement.scad>
use <../extensions/mirror_translate.scad>
use <../extensions/renamed_commands.scad>
use <../extensions/easy_joints.scad>

stud_width = 40;
stud_height = 600;
stud_depth = 80;
joint_size = 80;

module base_stud() {
  cube([stud_depth, stud_height, stud_width]);
}

module puzzle_stud() {
  puzzle1_top = 0.5 * stud_height - joint_size;

  module half_stud() {
    cube([stud_depth, puzzle1_top, stud_width]);
    bw(puzzle1_top)
      puzzle_joint(stud_depth, joint_size, stud_width);
  }

  bw(0.5 * stud_height) {
    half_stud();
    mirror([0, 1, 0]) half_stud();
  }
}

module bottom_stud () {
  difference() {
    rg(0.5 * stud_height + 0.5 * stud_width)
      rotate([0, 0, 90])
        base_stud();
    #dn(0.5 * stud_width)
      scale([1, 1, 2])
        puzzle_stud();
  }
}

*puzzle_stud();
bottom_stud();
