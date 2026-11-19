// Dim unfocused window effect (darken RGB without changing opacity)
vec4 window(vec2 uv) {
  vec4 c = umbriel_sample(uv);
  return vec4(c.rgb * 0.70, c.a);
}
