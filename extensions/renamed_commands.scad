use <./easy_vector.scad>
use <./Round-Anything/polyround.scad>

module round_corners(points, radius) {
  fn = $fn == 0 ? 32 : $fn;
  polygon(polyRound(plain_to_radii(points, radius), fn));
}

module polyround(radii_points) {
  fn = $fn == 0 ? 32 : $fn;
  polygon(polyRound(radii_points, fn));
}

module beam(radii_points, offset1, offset2) {
  fn = $fn == 0 ? 32 : $fn;
  polygon(polyRound(beamChain(radii_points, offset1, offset2), fn));
}

module extrude(height, scale, center) {
  linear_extrude(height = height, scale = scale, center = center) children();
}
