use <../extensions/easy_debug.scad>
use <../extensions/easy_movement.scad>
use <../extensions/renamed_commands.scad>

width = 700;
height = 350;
depth = 350;

border_size = 80;

side_thickness = 19;
top_thickness = 19;
bottom_thickness = 12;
back_panel_thickness = 6;

bit_diameter = 1/4 * 25.4;

$fn = 64;

module large_plank_bottom_front(debug = true) {
  w = width - 2 * border_size;
  d = border_size;

  if (debug) {
    show([[0, d + 10], [w, d + 10]]);
    show([[w + 10, 0], [w + 10, d]]);
  }
  extrude(bottom_thickness)
    square([w, d]);
}

module large_plank(discount_back_panel = false) {
  w = width - 2 * border_size;
  d = discount_back_panel
    ? border_size - back_panel_thickness
    : border_size;

  *show([[0, -10], [w, -10]]);
  *show([[-10, 0], [-10, d]]);
  square([w, d]);
}

module medium_plank_bottom(debug = false) {
  w = depth - back_panel_thickness;
  d = border_size - side_thickness;

  if (debug) {
    show([[0, d + 10], [w, d + 10]]);
    show([[w + 10, 0], [w + 10, d]]);
  }

  extrude(bottom_thickness)
    square([w, d]);
}

module medium_plank(discount_back_panel_d = false,
                    discount_back_panel_w = false) {
  w = discount_back_panel_w
    ? border_size - back_panel_thickness
    : border_size;
  d = discount_back_panel_d
    ? depth - back_panel_thickness
    : depth;

  *show([[0, -10], [w, -10]]);
  *show([[-10, 0], [-10, d]]);
  square([w, d]);
}

module short_plank() {
  w = border_size;
  d = depth - 2 * border_size;

  *show([[0, -10], [w, -10]]);
  *show([[-10, 0], [-10, d]]);
  square([w, d]);
}

module large_panel() {
  union() {
    // Left plank
    rg(border_size - side_thickness)
      rotate([0, 0, 90])
        medium_plank_bottom();

    // Right plank
    rg(width - 2 * side_thickness)
      rotate([0, 0, 90])
        medium_plank_bottom();

    // Front plank
    rg(border_size - side_thickness)
      large_plank();

    // Back plank
    rg(border_size - side_thickness)
      bw(depth - border_size)
        large_plank(discount_back_panel = true);
  }
}

module small_panel() {
  union() {
    // Left plank
    medium_plank(discount_back_panel_w = true);

    // Right plank
    rg(depth - border_size - back_panel_thickness)
      medium_plank();

    // Front plank
    rg(border_size - back_panel_thickness)
      bw(border_size)
        rotate([0, 0, -90])
          short_plank();

    // Back plank
    rg(border_size - back_panel_thickness)
      bw(depth)
        rotate([0, 0, -90])
          short_plank();
  }
}

*medium_plank_bottom();
large_plank_bottom_front();
*large_panel();
*small_panel();
