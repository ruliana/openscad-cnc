use <easy_vector.scad>

function dogbone() = [for (angle = [45, 135, 225, 315]) rot([1, 0], angle)];
function u_shaped() = [[1, 0], [-1, 0], [-1, 0], [1, 0]];
function u_shaped_south() = [[1, 0], [-1, 0], false, false];
function t_shaped() = [[0, 1], [0, 1], [0, -1], [0, -1]];

function center() = [-1/2, -1/2];
function north() =[-1/2, -1];
function south() =[-1/2, 0];
function east() =[-1, -1/2];
function west() =[0, -1/2];
function sw() = [0, 0];
function se() = [-1, 0];
function ne() = [-1, -1];
function nw() = [0, -1];

module pocket(width, height, bit_diameter=3.175, clearance=0.05, snap_point=sw(), fillet=dogbone()) {
  bit_radius = bit_diameter / 2;

  right = width + clearance;
  left = 0 - clearance;
  top = height + clearance;
  bottom = 0 - clearance;

  points = [[left, bottom],
            [right, bottom],
            [right, top],
            [left, top]];

  fillet_points = [for (i = [0:3]) if (fillet[i]) points[i] + bit_radius * fillet[i]];

  translate([width * snap_point.x, height * snap_point.y]) {
    polygon(points);
    for (point = fillet_points) translate(point) circle(d=bit_diameter);
  }
}
