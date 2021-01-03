$fn = 200;

thickness = 6;
radius = 32;
height = 80;
slice_height = 19.05;
slices = 3;
chamfre_height = 2;

include_register_holes = true;
register_hole_distance = 50;

// Larger value for cutting shapes
i_dont_care = 10;

slack = 0.2;

module frame(thickness) {
  difference() {
    children();
    offset(-thickness) children();
  }
}

module border() {
  linear_extrude(slice_height)
    frame(thickness) circle(radius);
}

module chamfre() {
    circle(radius - 1/2 * thickness);
}

module inner_chamfre() {
  linear_extrude(i_dont_care)
    offset(-slack) chamfre();
}

module outer_chamfre() {
  translate([0, 0, chamfre_height - i_dont_care + 1/2 * slack]) {
    linear_extrude(i_dont_care) {
      difference() {
        circle(radius + i_dont_care);
        offset(slack) chamfre();
      }
    }
  }
}

module cup_slice() {
  difference() {
    border();
    translate([0, 0, slice_height - chamfre_height - 1/2 * slack])
      inner_chamfre();
    outer_chamfre();
  }
}

module cup_base() {
  difference() {
    linear_extrude(thickness)
      circle(radius);
    translate([0, 0, thickness - chamfre_height + 1/2 * slack])
      inner_chamfre();
  }
}

// Register holes for double side milling
module register_hole(x) {
  translate([x, 0, 0]) {
    linear_extrude(slice_height) {
      difference() {
        offset(5) circle(1/8 * 25.4);
        circle(1/8 * 25.4 / 2);
      }
    }
  }
}

module flat_pack() {
  for (i = [0:slices]) {
    center = i * (2 * radius + 10);
    if (i == 0) {
      cup_base();
    } else {
      translate([center, 0, 0]) cup_slice();
    }
    if (include_register_holes) {
      if (i == 0) register_hole(center - register_hole_distance);
      if (i == slices) register_hole(center + register_hole_distance);
    }
  }
}

module assembled() {
  for (i = [0:slices]) {
    bottom = i * (slice_height - chamfre_height) - (slice_height - thickness);
    if (i == 0) {
      cup_base();
    } else {
      translate([0, 0, bottom]) cup_slice();
    }
  }
}

!assembled();
flat_pack();
