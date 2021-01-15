use <Shopify Sans-Extrabold.otf>;
$fn=150;
bit_diameter = 1/8 * 25.4;
bit_radius = bit_diameter / 2;

width = 320;

base_width = 96.0;
nominal_width = width * (96.0 / base_width);
nominal_depth = width * (71.6 / base_width);
left_by = (width * (98 / base_width)) / 2;
up_by = (width * (2.7 / base_width)) / 2;
text_size = width * (20.0 / base_width);

echo(str("width: ", nominal_width));
echo(str("depth: ", nominal_depth));

module round(by) {
  offset(-by)
    offset(by)
      children();
}

module write(string, size=1, spacing=0.83, pos=[0, 0, 0]) {
  translate([text_size * pos.x, text_size * pos.y, text_size * pos.z])
    text(string,
         spacing=spacing,
         halign="left",
         valign="center",
         font="Shopify Sans:style=Extrabold",
         size=text_size * size);
}

translate([-width / 2, 0, 0]) {
  union() {
    linear_extrude(20)
      offset(-2)
        round(bit_radius)
          write("Shopify", pos=[0, 1.2, 0]);
    linear_extrude(15)
      offset(-2)
        round(bit_radius)
          write("@", pos=[1.7, -0.28, 0], size=2.5);
    linear_extrude(23)
      offset(-2)
        round(bit_radius)
          write("127.0.0.1", pos=[0.8, -1.22, 0], size=0.9);
  }

  *translate([left_by, up_by, 0]) square([nominal_width, nominal_depth], center=true);
}
