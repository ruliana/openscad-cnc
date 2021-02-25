use <easy_vector.scad>

module plot_point(point, radius, legend=false, extrude=0.7) {
  tint = "Violet";
  color(tint)
    translate([point.x, point.y])
      linear_extrude(extrude)
        circle(r=radius);

  if (legend != false) {
    color(tint)
      translate([point.x, point.y] + [radius, radius])
        linear_extrude(extrude)
          text(str(legend));
  }
}

module plot_points(points, radius, info) {
  for (point = points) plot_point(point, radius);
}

module plot_line(line, radius, info) {
  tint = "Plum";
  color(tint)
    hull() {
    plot_point(line[0], radius / 2);
    plot_point(line[1], radius / 2);
  }
  plot_point(line[0], radius, extrude=0.8);
  plot_point(line[1], radius, extrude=0.8);

  measurement = round(norm(line[1] - line[0]) * 100) / 100;
  color(tint)
    snap(mid(line) + [radius, radius])
      linear_extrude(0.8)
        text(str(measurement));
}

module show(thing, radius=3) {
  if (is_point(thing)) {
    plot_point(thing, radius );
  } else if (is_line(thing)) {
    plot_line(thing, radius);
  } else if (is_polyline(thing)) {
    for (i = [0:len(thing) - 1]) plot_point(thing[i], radius, i);
  }
}
