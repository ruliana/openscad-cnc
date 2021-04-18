use <../extensions/easy_vector.scad>
use <../extensions/easy_debug.scad>
use <../extensions/Round-Anything/polyround.scad>

shelf_width = 350;
shelf_height = 380;
shelf_top_depth = 250;
shelf_base_depth = 350;

function rpoint(vec, radius=0) = is_radii_point(vec) ? vec : [vec.x, vec.y, radius];

function leg_outline() =
  [
   [0, 0],
   [0.5 * shelf_base_depth, 0],
   [0.5 * shelf_top_depth, shelf_height],
   [0, shelf_height],
  ];


function leg_inline() =
  let(
      r = leg_outline(),
      leg_base_inner = parallel([r[0], r[1]], 60),
      leg_outer_inner = parallel([r[1], r[2]], 60),
      leg_top_inner = parallel([r[2], r[3]], 60),

      leg_cross_se = crossing(leg_base_inner, leg_outer_inner),
      leg_cross_ne = crossing(leg_top_inner, leg_outer_inner),
      leg_cross_nw = r[3] - [0, 60],
      leg_cross_sw = r[0] + [0, 60]
      )
    [leg_cross_sw,
     leg_cross_se,
     leg_cross_ne,
     leg_cross_nw];


function apply_leg_radii(leg, radius) =
  [rpoint(leg[0], 0),
   rpoint(leg[1], radius),
   rpoint(leg[2], radius),
   rpoint(leg[3], 0)];


show(leg_outline());
show(leg_inline());

difference() {
  polygon(polyRound(apply_leg_radii(leg_outline(), 30)));
  polygon(polyRound(apply_leg_radii(leg_inline(), 10)));
}


/* new_points = apply(points, rot(45) * scl(1.2) * mov([100, 100])); */
/* show(new_points); */
