shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// Original Blender geometry is kept as the permanent editable source.
// The shader deforms only the visible skin, not collision or saved character geometry.
uniform vec3 node_rest[13];
uniform vec3 node_shift[13];
uniform float radius_multiplier : hint_range(0.2, 2.0) = 0.80;

uniform vec4 gel_color : source_color = vec4(0.035, 0.45, 0.25, 1.0);
uniform vec4 soft_center : source_color = vec4(0.26, 0.88, 0.39, 1.0);
uniform vec4 gel_edge : source_color = vec4(0.035, 0.25, 0.22, 1.0);
uniform float edge_glow : hint_range(0.0, 0.5) = 0.07;

varying vec3 local_position;

void vertex() {
    vec3 original = VERTEX;
    vec3 deviation = vec3(0.0);
    float coverage = 0.0;
    for (int i = 0; i < 13; i++) {
        float radius = radius_multiplier;
        float dist2 = dot(original - node_rest[i], original - node_rest[i]);
        float weight = exp(-dist2 / max(0.01, (2.0 * radius * radius)));
        deviation += node_shift[i] * weight;
        coverage += weight;
    }
    deviation /= max(0.7, coverage * 0.78);
    // Approximate volume conservation: axial stretch narrows local radius,
    // compression widens it. Lower contour stays planted.
    float upper_stretch = clamp(node_shift[1].y + node_shift[2].y +
                                node_shift[3].y + node_shift[4].y, -1.5, 1.5) * 0.25;
    float radial_balance = clamp(1.0 - upper_stretch * 0.26, 0.81, 1.22);
    VERTEX.xz *= radial_balance;
    VERTEX += deviation;
    local_position = VERTEX;
}

// Camera-independent green-depth illusion for single-threaded WebGL2.
// True transparency/refraction would degrade both speed and face readability.
void fragment() {
    vec3 n = normalize(NORMAL);
    vec3 v = normalize(VIEW);
    float rim = pow(1.0 - clamp(dot(n,v), 0.0, 1.0), 2.55);
    float height_t = smoothstep(0.11, 1.83, local_position.y);
    float crown = smoothstep(0.60, 1.0, height_t);
    float lower_absorption = 1.0 - smoothstep(0.2, 0.82, height_t);
    vec3 base = mix(gel_color.rgb, soft_center.rgb, height_t * 0.95);
    base *= 1.0 - lower_absorption * 0.12;
    // Subsurface-inspired cyan side-light and warm translucent core.
    float glow_core = exp(-pow(local_position.x * 0.91, 2.0) / 0.68)
                    * smoothstep(0.28, 1.08, local_position.y)
                    * (1.0 - smoothstep(1.35, 1.90, local_position.y));
    base += vec3(0.042, 0.12, 0.052) * glow_core;
    float edge_mix = clamp(rim * (0.55 + 0.14 * crown), 0.0, 0.62);
    ALBEDO = mix(base, gel_edge.rgb, edge_mix);
    METALLIC = 0.0;
    ROUGHNESS = 0.145;
    SPECULAR = 0.89;
    EMISSION = base * rim * edge_glow;
}
