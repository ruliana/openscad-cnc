use <../extensions/easy_movement.scad>
use <../extensions/easy_vector.scad>
use <../extensions/renamed_commands.scad>
use <../extensions/easy_pocket.scad>
use <../extensions/easy_debug.scad>

/* [Exhibition] */
show = "assembled"; // [assembled:Assembled, top:Top, left_leg:Left Leg, right_leg:Right Leg, support:Support]
exploding_distance = 0; // [0:20:200]

/* [Dimensions] */
desk_height = 505;
desk_width = 600;
desk_depth = 500;

/* [Style] */
handle_width = 120;
handle_height = 50;
handle_distance_from_top = 80;
support_height = 150;

/* [Construction] */
leg_thickness = 19.5;
top_thickness = 12;
bit_diameter = 6.35;

leg_height = desk_height - top_thickness;
support_width = desk_width - leg_thickness;
support_distance = desk_depth / 2 + handle_width / 2 + 10;

module dummy() {
  cube([desk_width, desk_depth, desk_height]);
}

module top_pocket() {
  // The "1" below is just for getting a clean
  // difference from the top.
  dn(1)
    extrude(top_thickness / 2 + 1)
      pocket(support_width,
            leg_thickness,
            bit_diameter);
}

module desk_top() {
  difference() {
    extrude(top_thickness)
      square([desk_width, desk_depth]);
    bw(support_distance)
      rg(leg_thickness / 2)
        top_pocket();
  }
}

module leg_pocket() {
  $fn = 64;
  height = min(support_height, desk_height);
  extrude(leg_thickness)
    pocket(height,
           leg_thickness,
           bit_diameter,
           fillet=dogbone_west());

}

module leg_hole() {
  bw(desk_depth / 2 - handle_width / 2)
    hull() {
      bw(handle_height / 2)
        circle(d = handle_height);
      bw(handle_width - handle_height / 2)
        circle(d = handle_height);
  }
}

module desk_leg() {
  extrude(leg_thickness)
  difference() {
    square([leg_height, desk_depth]);
    rg(leg_height - handle_distance_from_top)
      leg_hole();
  }
}

module desk_support() {
  height = support_height;
  extrude(leg_thickness)
    square([support_width, height + top_thickness / 2]);
}

module right_leg() {
  difference() {
    desk_leg();
    up(leg_thickness / 2)
      rg(leg_height - support_height)
        bw(support_distance)
          leg_pocket();
  }
}

module left_leg() {
  mirror([1, 0, 0])
    right_leg();
}

module exploded(exploding_distance = 100) {
  // Top
  up(desk_height - top_thickness + exploding_distance)
    desk_top();

  // Left leg
  lf(exploding_distance)
    rotate([0, 90, 0])
      left_leg();

  // Right leg
  rg(desk_width + exploding_distance)
    rotate([0, -90, 0])
      right_leg();

  // Middle support
  up(desk_height - support_height - top_thickness)
    rg(leg_thickness / 2)
      bw(leg_thickness + support_distance)
        rotate([90, 0, 0])
          desk_support();
}

module flat_right_leg() {
  rg(desk_depth)
    rotate([0, 0, 90])
      right_leg();
}

module flat_left_leg() {
  rotate([0, 0, -90])
    left_leg();
}

module flat_support() {
  desk_support();
}

module flat_top() {
  rg(desk_width)
    rotate([0, 180, 0])
      desk_top();
}

if (show == "assembled") {
  exploded(exploding_distance);
} else if (show == "top") {
  flat_top();
} else if (show == "left_leg") {
  flat_left_leg();
} else if (show == "right_leg") {
  flat_right_leg();
} else if (show == "support") {
  flat_support();
}
