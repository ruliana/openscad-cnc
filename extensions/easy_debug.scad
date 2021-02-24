use <easy_vector.scad>

module plot_point(point, radius, info) {
  #translate([point.x, point.y, 0.01]) circle(r=radius);
}

module plot_points(points, radius, info) {
  for (point = points) plot_point(point, radius);
}

module plot_line(line, radius, info) {
  color("LightBlue")
    hull() {
    plot_point(line[0], radius / 2);
    plot_point(line[1], radius / 2);
  }
  plot_point(line[0], radius);
  plot_point(line[1], radius);
}

module show(thing, radius=5, info=true) {
  if (is_point(thing)) {
    plot_point(thing, radius, info);
  } else if (is_line(thing)) {
    plot_line(thing, radius, info);
  } else if (is_polyline(thing)) {
    for (point = thing) plot_point(point, radius, info);
  }
}
