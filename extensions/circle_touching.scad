// Find the center of a circle that passes through 3 points.
module circle_touching(p1, p2, p3) {
  function gradient(p1, p2) = (p1.y - p2.y) / (p1.x - p2.x);
  function perpendicular_gradient(p1, p2) = - 1 / gradient(p1, p2);
  function circle_center_touching(p1, p2, p3) =
    let (m1 = (p1 + p2) / 2,
         m2 = (p1 + p3) / 2,
         g1 = perpendicular_gradient(p1, p2),
         g2 = perpendicular_gradient(p1, p3),
         x = (g1 * m1.x - m1.y - g2 * m2.x + m2.y) / (g1 - g2),
         y = g1 * x - g1 * m1.x + m1.y)
    [x, y];

  center = circle_center_touching(p1, p2, p3);
  radius = norm(center - p1);
  translate(center) circle(radius);
}
