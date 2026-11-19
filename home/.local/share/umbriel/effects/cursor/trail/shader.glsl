// The bundled trail, drawn as a Catmull-Rom curve through the motion samples.
// Tangents follow sample times, so the short newest segment does not overshoot.
const float kLife = 0.3;
const float kMaxWidth = 3.5;

vec3 trailTint(float life) {
  vec3 tint = mix(vec3(0.22, 0.16, 0.38), vec3(0.65, 0.61, 0.91), smoothstep(0.0, 0.65, life));
  return mix(tint, vec3(0.98, 0.93, 0.61), smoothstep(0.75, 1.0, life));
}

// Curve from p1 to p2; p0 and p3 are its neighbours (repeated at the ends).
void trailSegment(vec2 uv, vec4 p0, vec4 p1, vec4 p2, vec4 p3, inout float coverage, inout vec3 colour) {
  vec2 here = uv * umbriel_size;
  vec2 a = p1.xy * umbriel_size;
  vec2 b = p2.xy * umbriel_size;
  vec2 chord = b - a;
  float dt = max(p1.z - p2.z, 0.001);
  vec2 m0 = (b - p0.xy * umbriel_size) * dt / max(p0.z - p2.z, 0.001);
  vec2 m1 = (p3.xy * umbriel_size - a) * dt / max(p1.z - p3.z, 0.001);
  // A warp or jump reads as near-infinite speed; cap tangents so it cannot loop.
  float limit = 1.5 * length(chord);
  m0 *= min(1.0, limit / max(length(m0), 0.001));
  m1 *= min(1.0, limit / max(length(m1), 0.001));
  // A Hermite segment strays from its chord by at most 4/27 of each tangent's departure from it.
  float bulge = (4.0 / 27.0) * (length(m0 - chord) + length(m1 - chord));
  vec2 offset = here - a;
  float t = clamp(dot(offset, chord) / max(dot(chord, chord), 0.001), 0.0, 1.0);
  if (length(offset - chord * t) > bulge + 3.0 * kMaxWidth) {
    return;
  }
  vec2 previous = a;
  for (int j = 1; j <= 6; ++j) {
    float s = float(j) / 6.0;
    float s2 = s * s;
    float s3 = s2 * s;
    vec2 point =
        (2.0 * s3 - 3.0 * s2 + 1.0) * a + (s3 - 2.0 * s2 + s) * m0 + (3.0 * s2 - 2.0 * s3) * b + (s3 - s2) * m1;
    vec2 piece = point - previous;
    vec2 rel = here - previous;
    float u = clamp(dot(rel, piece) / max(dot(piece, piece), 0.001), 0.0, 1.0);
    float life = clamp(1.0 - mix(p1.z, p2.z, (float(j) - 1.0 + u) / 6.0) / kLife, 0.0, 1.0);
    float d = length(rel - piece * u);
    float width = mix(0.5, kMaxWidth, life);
    float glow = exp(-d * d / (width * width)) * life * life;
    if (glow > coverage) {
      coverage = glow;
      colour = trailTint(life);
    }
    previous = point;
  }
}

vec4 cursor(vec2 uv) {
  vec4 background = umbriel_sample(uv);
  float coverage = 0.0;
  vec3 colour = vec3(0.0);
  // Sliding window over the samples: p0..p3 = samples k-3..k, clamped at the oldest.
  vec4 p0 = vec4(0.0);
  vec4 p1 = p0;
  vec4 p2 = p0;
  vec4 p3 = p0;
  for (int k = 0; k < 8; ++k) {
    if (k < umbriel_pointer_count) {
      vec4 next = umbriel_pointer_history[k];
      if (k == 0) {
        p1 = next;
        p2 = next;
        p3 = next;
      }
      p0 = p1;
      p1 = p2;
      p2 = p3;
      p3 = next;
      if (k >= 2) {
        trailSegment(uv, p0, p1, p2, p3, coverage, colour);
      }
    }
  }
  if (umbriel_pointer_count >= 2) {
    trailSegment(uv, p1, p2, p3, p3, coverage, colour);
  }
  return mix(background, vec4(colour, 1.0), coverage * 0.85);
}
