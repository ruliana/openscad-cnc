use <Round-Anything/polyround.scad>

function round_corners(target, radius) =
  polyRound(plain_to_radii(target, radius), $fn);

module polyround(radii_points) {
  fn = $fn == 0 ? 32 : $fn;
  polygon(polyRound(radii_points, fn));
}

module extrude(z_direction) {
  linear_extrude(z_direction) children();
}
