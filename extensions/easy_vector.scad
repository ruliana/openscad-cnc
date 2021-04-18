use <Round-Anything/polyround.scad>
/*
Fundamental types:
   Plain point is [x, y]
   Radii point is [x, y, radius]
   Point is a simple point or radii point
   Line is [point, point]
   Polyline is [point, point, point...]

   Points or Lines are Polylines.
*/

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

function plain_to_radii(target, radius) =
  [for (p = target) [p.x, p.y, radius]];

function round_corners(target, radius) =
  polyRound(plain_to_radii(target, radius), $fn);

/* Create basis transformation functions */
function basis_transformer(target_origin, target_x, target_y) =
  let(new_x = (target_x - target_origin) / norm(target_x - target_origin),
      new_y = (target_y - target_origin) / norm(target_y - target_origin))
    function (vec) vec.x * new_x + vec.y * new_y + target_origin;

/* Rotate a 2D vector by a given angle (on the z-axis) */
/* Deprecated: use "rot" + multiplication */
function rotation(vec, angle) =
  [vec.x * cos(angle) - vec.y * sin(angle),
   vec.x * sin(angle) + vec.y * cos(angle)];

/* Point in line v1-->v2 that's _target_ distance from v1. */
/* Target can also be a vector, in this case, y will be */
/* perpendicular to the line. */
function in_line(line, target, restrict=false) =
  let(original_vector = line[1] - line[0],
      unit_x = original_vector / norm(original_vector),
      unit_y = rotation(unit_x, 90),
      new_vector = is_num(target)
        ? target * unit_x
        : target.x * unit_x + target.y * unit_y)
  !restrict ? new_vector + line[0]
  : norm(new_vector) > norm(original_vector) ? line[1]
  : norm(new_vector) < 0 ? line[0]
  : new_vector + line[0];

/* Mirrors the object around line center. */
module in_line_mirror(line, distance, restrict=false) {
  center = mid(line);
  right_line = [center, line[1]];
  left_line = [center, line[0]];

  dist = is_num(distance) ? distance : [distance.x, -distance.y];
  left_anchor = in_line(left_line, dist, restrict=restrict);
  right_anchor = in_line(right_line, distance, restrict=restrict);

  translate(left_anchor)
    children();

  translate(right_anchor)
    mirror([1, 0, 0]) children();
}

/* Parallel line at distance from the given one */
function parallel(line, distance) =
  [in_line([line.x, line.y], [0, distance]),
   in_line([line.y, line.x], [0, -distance])];

/* Point crossing 2 lines */
// TODO: Test parallel lines
// TODO: Test collinear lines
function crossing(line1, line2) =
  let(cross_product = function(v1, v2) v1.x * v2.y - v1.y * v2.x,
      p = radii_to_plain(line1[0]),
      r = radii_to_plain(line1[1] - line1[0]),
      q = radii_to_plain(line2[0]),
      s = radii_to_plain(line2[1] - line2[0]),
      t = cross_product((q - p), s) / cross_product(r, s))
    p + t * r;

/* That's exactly translate, but the intention is */
/* clearer. I want to "glue" the [0, 0] point of */
/* this object to the destination vector. */
module snap(to_point) {
  // TODO: extend to snap to a line.
  translate(radii_to_plain(to_point)) children();
}


/*
  Matrix transformations
*/

function to_affine(vecs) = [for (v = vecs) [v.x, v.y, 1]];

function from_affine(vecs) = [for (v = vecs) [v.x, v.y]];

function apply(vecs, transformations) = from_affine(to_affine(vecs) * transformations);

function rot(angle) =
  let(a = angle)
    [[ cos(a), sin(a),     0],
     [-sin(a), cos(a),     0],
     [      0,      0,     1]];

function mov(target) =
  let(t = target)
    [[1  ,   0,   0],
     [0  ,   1,   0],
     [t.x, t.y,   1]];

function scl(factor) =
  let(f = factor)
    [[f, 0, 0],
     [0, f, 0],
     [0, 0, 1]];

function mirror_x() =
  [[-1, 0, 0],
   [ 0, 1, 0],
   [ 0, 0, 1]];

function mirror_y() =
  [[1,  0, 0],
   [0, -1, 0],
   [0,  0, 1]];

inner_sum = function(rslt, vecs, index)
  let(size = len(vecs))
    index >= size
    ? rslt
    : inner_sum(rslt + vecs[index], vecs, index + 1);

function sum(vecs) =
  let(size = len(vecs))
    len(vecs) > 1
    ? inner_sum(vecs[0], vecs, 1)
    : vecs[0];

function avg(vecs) = sum(vecs) / len(vecs);

/* Center of a polygon or line */
function center(vecs) = avg(vecs);

/* Mid point of a line */
function mid(v1, v2=[0, 0]) =
  let(a = is_line(v1) ? radii_to_plain(v1[0]) : radii_to_plain(v1),
      b = is_line(v1) ? radii_to_plain(v1[1]) : radii_to_plain(v2))
  a + (b - a) / 2;

/* TODO Snap vecs to vec */
/* TODO Snap vecs to line */
/* TODO Restrict to line */
/* TODO Scale (up/down) to bounding box */
/* TODO Function chain */
