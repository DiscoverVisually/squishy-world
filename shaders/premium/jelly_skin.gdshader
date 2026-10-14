shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// Original Blender geometry is kept as the permanent editable source.
// The shader deforms only the visible skin, not collision or saved character geometry.
uniform vec3 node_rest[13];
uniform vec3 node_shift[13];
uniform float radius_multiplier : hint_range(0.2, 2.0) = 0.80;

uniform vec4 gel_color : source_color = vec4(0.13, 0.74, 0.39, 1.0);
uniform vec4 soft_center : source_color = vec4(0.27, 0.88, 0.50, 1.0);
uniform vec4 gel_edge : source_color = vec4(0.05, 0.40, 0.35, 1.0);
uniform float edge_glow : hint_range(0.0, 0.5) = 0.10;

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

void fragment() {
    vec3 normal_dir = normalize(NORMAL);
    vec3 view_dir = normalize(VIEW);
    float rim = pow(1.0 - clamp(dot(normal_dir, view_dir), 0.0, 1.0), 3.0);
    float translucency_illusion = smoothstep(0.4, 1.9, local_position.y);
    vec3 base = mix(gel_color.rgb, soft_center.rgb, translucency_illusion * 0.36);
    ALBEDO = mix(base, gel_edge.rgb, rim * 0.40);
    ROUGHNESS = 0.20;
    SPECULAR = 0.66;
    METALLIC = 0.0;
    EMISSION = gel_color.rgb * rim * edge_glow;
}
