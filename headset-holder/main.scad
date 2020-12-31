function hyp(radius) = sqrt(2 * pow(radius, 2));

INCH_TO_MM = 25.4;
$fn=50;
width = 250;
height = 250;
depth = 250;
thickness = 3/4 * INCH_TO_MM;
bit = 1/8 * INCH_TO_MM;
bit_radius = bit / 2;
dog_bone = hyp(bit_radius);
pocket_slack = 0.05;

foot_height = thickness;
foot_radius = 80;
pole_width = 50;

holder_pocket_depth = 25;

// Find the center of a circle that passes through 3 points.
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

module circle_touching(p1, p2, p3) {
  center = circle_center_touching(p1, p2, p3);
  radius = norm(center - p1);
  translate(center) circle(radius);
}


module foot() {
  difference() {
    linear_extrude(foot_height)
      circle(foot_radius, $fn=200);
    foot_pocket();
  }
}

module foot_pocket() {
  translate([0, 0, 2]) {
    linear_extrude(foot_height) {
      union() {
        thick = (thickness + pocket_slack) / 2;
        w = (pole_width + pocket_slack) / 2;
        square([pole_width + pocket_slack, thickness + pocket_slack], center=true);
        translate([w - dog_bone, thick - dog_bone]) circle(bit);
        translate([w - dog_bone, -thick + dog_bone]) circle(bit);
        translate([-w + dog_bone, thick - dog_bone]) circle(bit);
        translate([-w + dog_bone, -thick + dog_bone]) circle(bit);
      }
    }
  }
}

module pole() {
  difference() {
    cube([pole_width, thickness, height - 2], center=true);
    pole_carve_left();
    pole_carve_right();
  }
}

module pole_carve_left() {
  rotate([90, 0, 0]) {
    p1 = [pole_width / 2, height / 2 - 20];
    p2 = [10, 0];
    p3 = [pole_width / 2, -height / 2 + 16.4];

    linear_extrude(thickness + 1, center=true)
      circle_touching(p1, p2, p3, $fn=100);
  }
}

module pole_carve_right() {
  rotate([90, 0, 0]) {
    p1 = [-pole_width / 2, height / 2 - 11];
    p2 = [-10, 0];
    p3 = [-pole_width / 2, -height / 2 + 16.4];

    linear_extrude(thickness + 1, center=true)
      circle_touching(p1, p2, p3, $fn=100);
  }
}

module holder_cap() {
  length = 75;
  cut = 67;
  subtract_radius = thickness - 2;
  adjacent = length - cut;

  dist_from_inner_circle = (thickness * (adjacent / sqrt(pow(subtract_radius, 2) - pow(adjacent, 2))));
  outer_circle_x = length - dist_from_inner_circle;
  small_radius = sqrt(pow(dist_from_inner_circle, 2) + pow(thickness, 2)) - subtract_radius;

  rotate([0, 0, 10]) {
    rotate_extrude(angle=140, $fn=100) {
      difference() {
        square([cut, thickness]);
        translate([length, thickness]) circle(subtract_radius);
      }
      translate([outer_circle_x, 0]) {
        intersection() {
          circle(small_radius);
          square(small_radius);
        }
      }
    }
  }
}

module holder_pocket() {
  d = holder_pocket_depth / 2;
  w = (pole_width + pocket_slack) / 2;
  translate([0, d, thickness + pocket_slack / 2]) {
    cube([pole_width + pocket_slack, holder_pocket_depth, thickness + pocket_slack], center=true);
    translate([w - dog_bone, d  - dog_bone, 0])
      cylinder(thickness + pocket_slack, bit, bit, center=true);
    translate([-w + dog_bone, d - dog_bone, 0])
      cylinder(thickness + pocket_slack, bit, bit, center=true);
  }
}

module holder() {
  difference() {
    holder_cap();
    holder_pocket();
  }
}


// Assemble
module assembled() {
  foot();
  translate([0, 0, height / 2 + 2]) pole();
  translate([0, thickness, height - holder_pocket_depth + 1])
    rotate(90, [1, 0, 0])
    holder();
    
  mirror([0, 1, 0])
    translate([0, thickness, height - holder_pocket_depth + 1])
    rotate(90, [1, 0, 0])
    holder();
}


// CNC positioning
module flat_pack() {
  translate([-50, 0, 0]) foot();
  translate([13, 60, 0]) rotate([0, 0, -45]) holder();
  mirror([0, 1, 0]) translate([13, 60, 0]) rotate([0, 0, -45]) holder();
  translate([105, 0, thickness / 2]) rotate([90, 0, 0]) pole();
}

/* assembled(); */

// Surface to fit
/* %square([270, 270], center=true); */
flat_pack();
