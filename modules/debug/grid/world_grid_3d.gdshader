shader_type spatial;

const float MARCH_THRESHOLD = 0.001;

uniform vec3 base_color : source_color = vec3(0.333);
uniform float dot_radius = 0.01;
uniform float dot_spacing = 1.0;
uniform float max_render_distance = 10.0;
uniform int march_precision = 16;
uniform float orientation_hinting_strength = 0.1;

float sdf_sphere(vec3 p, float r) {
    return length(p) - r;
}

void fragment() { 
	// 1. Camera origin (world space)
    vec3 ro = CAMERA_POSITION_WORLD;

    // 2. Ray direction (world space)
    vec2 ndc = (FRAGCOORD.xy / VIEWPORT_SIZE) * 2.0 - 1.0; // NDC [-1,1]
    vec4 clip = vec4(ndc, 1.0, 1.0);
    vec4 view = INV_PROJECTION_MATRIX * clip;
    view /= view.w;
    vec3 rd = normalize((INV_VIEW_MATRIX * vec4(view.xyz, 0.0)).xyz);

    // 3. Raymarch
    float t = 0.0;
	bool render = false;
    for (int i = 0; i < march_precision; i++) {
        vec3 p = ro + rd * t;
        vec3 nearest = round(p / dot_spacing) * dot_spacing;
        float d = sdf_sphere(p - nearest, dot_radius);
		
		if (sdf_sphere(ro - nearest, dot_radius) < 0.0) {
			discard;
			break;
		}
		
        if (d < MARCH_THRESHOLD) {
			vec3 camera_direction = abs(CAMERA_DIRECTION_WORLD);
            NORMAL = normalize(p - nearest);
            ALBEDO = mix(base_color, camera_direction, orientation_hinting_strength);
            render = true;
        }
        t += d;
        if (t > max_render_distance) discard;
    }
	if (!render) {
		discard;
	}
}
