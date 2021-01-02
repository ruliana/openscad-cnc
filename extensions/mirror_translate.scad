// Mirrors the object translation
module mirror_translate(translation, copy=true) {
  if (copy) translate(translation) children();
  // mirror only what we moved
  m = [for (e = translation) e != 0 ? 1 : 0];
  mirror(m) translate(translation) children();
}
