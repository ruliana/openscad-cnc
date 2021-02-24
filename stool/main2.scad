use <../extensions/easy_debug.scad>
use <../extensions/easy_vector.scad>
use <../extensions/easy_movement.scad>
use <../extensions/easy_pocket.scad>
use <../extensions/Round-Anything/polyround.scad>

$fn = 32;

origin = [0, 0];

stool_height = 420;
seat_depth = 800;
leg_depth = 400;
material_thickness = 19.5;

bit_diameter = 3.175; //mm
bit_radius = bit_diameter / 2;

leg_height = [0, stool_height - material_thickness];
leg_top_depth = [seat_depth, 0] / 2;
leg_base_depth = [leg_depth, 0] / 2;
leg_thickness = 60;

function rpoint(vec, radius=0) = len(vec) == 3 ? vec : [vec.x, vec.y, radius];

function rpoints(vecs, radius=0) = [for (vec = vecs) rpoint(vec, radius)];

module leg() {
  // Key points
  recess = [leg_thickness, 0];
  top_right_ext = leg_height + leg_top_depth;
  top_right_int = top_right_ext - recess;
  top_right_mid = mid(top_right_int, top_right_ext);

  bottom_right_ext = leg_base_depth;
  bottom_right_int = bottom_right_ext - recess;
  bottom_right_mid = mid(bottom_right_int, bottom_right_ext);
  bottom_left_up = rot(recess, 90);

  leg_to_seat_dowel_height = [0, material_thickness / 2];

  // ==========
  // Components
  // ==========
  module leg_to_seat_dowel() {
    base_width = [leg_thickness, 0];
    gap = [material_thickness, 0];
    height = leg_to_seat_dowel_height;
    echo(-base_width + height);

    translate(-base_width /2 + height / 2)
      square(base_width - gap + height, center=true);
  }

  module leg_outline() {
    points = [origin,
              rpoint(bottom_right_ext, leg_thickness),
              top_right_ext,
              top_right_int,
              rpoint(in_line(bottom_right_int, top_right_int, leg_thickness), 1/2 * leg_thickness),
              bottom_left_up];

    show(points);

    polygon(polyRound(rpoints(points), 10));
  }

  module leg_pocket(snap_point) {
    width = material_thickness;
    height = leg_thickness;
    pocket(width, height, fillet=u_shaped_south(), snap_point=snap_point);
  }

  // ==========
  // Assemble
  // ==========
  difference() {
    union() {
      leg_outline();
      snap(top_right_ext)
        leg_to_seat_dowel();
    }
  snap(in_line(top_right_mid, bottom_right_mid, leg_thickness / 2 - leg_to_seat_dowel_height.y))
    leg_pocket(snap_point=center());
  }
}

*leg();

a = [1, 3];
b = [200, 150];
c = [220, 50];
d = [150, 70];

show([a, b]);
show([c, d]);

echo("========");
echo(crossing([a, b], [c, d]));
show(crossing([a, b], [c, d]));

echo("is_point");
echo(is_point(a));
echo(is_point([a, b]));
echo("is_line");
echo(is_line(a));
echo(is_line([a, b]));
echo("is_polyline");
echo(is_polyline(a));
echo(is_polyline([a, b]));
