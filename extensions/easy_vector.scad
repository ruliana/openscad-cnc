// Fundamental types:
// Plain point is [x, y]
// Radii point is [x, y, radius]
// Point is simple point or radii point
// Line is [point, point]
// Polyline is [point, point, point...]
//
// Points or Lines are Polylines.

function is_plain_point(target) =
  is_list(target) && len(target) == 2 && is_num(target.x) && is_num(target.y);

function is_radii_point(target) =
  is_list(target) && len(target) == 3 && is_num(target.x) && is_num(target.y) && is_num(target.z);

function is_point(target) =
  is_plain_point(target) || is_radii_point(target);

function is_line(target) =
  is_list(target) && len(target) == 2 && is_point(target[0]) && is_point(target[1]);

function is_polyline(target) =
  is_list(target) && len(target) > 0 && is_point(target[0]);

function radii_to_plain(target) =
  is_plain_point(target) ? target
  : is_radii_point(target) ? [target.x, target.y]
  : [for (p = target) radii_to_plain(p)];

// Create basis transformation functions
function basis_transformer(target_origin, target_x, target_y) =
  let(new_x = (target_x - target_origin) / norm(target_x - target_origin),
      new_y = (target_y - target_origin) / norm(target_y - target_origin))
    function (vec) vec.x * new_x + vec.y * new_y + target_origin;

// Rotate a 2D vector by a given angle (on the z-axis)
function rot(vec, angle) =
  [vec.x * cos(angle) - vec.y * sin(angle),
   vec.x * sin(angle) + vec.y * cos(angle)];

// Mid point of a line
function mid(v1, v2=[0, 0]) =
  let(a = is_line(v1) ? v1[0] : v1,
      b = is_line(v1) ? v1[1] : v2)
  a + (a - b) / 2;

// Point in line v1-->v2 that's _target_ distance from v1.
// Target can also be a vector, in this case, y will be
// perpendicular to the line.
// TODO: implement perpendicular
function in_line(v1, v2, target) =
  let(v = v2 - v1,
      unit_x = v / norm(v),
      unit_y = [0, 0])
  is_num(target)
  ? target * unit_x + v1
  : target.x * unit_x + target.y * unit_y + v1;

// Auxiliar to the function "crossing"
function cross_product(v1, v2) = v1.x * v2.y - v1.y * v2.x;

// Point crossing 2 lines
// TODO: Test parallel lines
// TODO: Test collinear lines
function crossing(line1, line2) =
  let(p = radii_to_plain(line1[0]),
      r = radii_to_plain(line1[1] - line1[0]),
      q = radii_to_plain(line2[0]),
      s = radii_to_plain(line2[1] - line2[0]),
      t = cross_product((q - p), s) / cross_product(r, s))
    p + t * r;

// That's exactly translate, but the intention is
// clearer. I want to "glue" the [0, 0] point of
// this object to the destination vector.
module snap(to_point) {
  // TODO: extend to snap to a line.
  translate(radii_to_plain(to_point)) children();
}
