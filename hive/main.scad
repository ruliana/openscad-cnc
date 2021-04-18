use <../extensions/easy_debug.scad>
use <../extensions/easy_vector.scad>
use <../extensions/easy_rotate.scad>
use <../extensions/easy_pocket.scad>
use <../extensions/mirror_translate.scad>
use <../extensions/Round-Anything/polyround.scad>

linear_extrude(1/8 * 25.4)
  import("stamps.svg");
