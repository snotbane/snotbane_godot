shader_type canvas_item;

const int PALETTE_SIZE = 36;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform vec3 palette[PALETTE_SIZE] : source_color;

const float PSX_DITHER_MATRIX[16] = float[](
    0.0,  8.0,  2.0, 10.0,
    12.0, 4.0, 14.0, 6.0,
    3.0, 11.0, 1.0,  9.0,
    15.0, 7.0, 13.0, 5.0
);

float dither(ivec2 uv) {	
	int xi = int(uv.x & 3); // mod 4
	int yi = int(uv.y & 3); // mod 4
	int di = xi + yi * 4;
	float dv = PSX_DITHER_MATRIX[di] / 16.0;
	
	return dv;
}

vec3 quantize(vec3 color, ivec2 uv) {
	float threshold = dither(uv);
	
	int nearest_index = 0;
	float nearest_distance = 1e20;
	
	for (int i = 0; i < 36; i++) {
		vec3 diff = color - palette[i];
		float dist = dot(diff, diff);
		if (dist >= nearest_distance) continue;
		
		nearest_distance = dist;
		nearest_index = i;
	}
	return palette[nearest_index];
}

void fragment() {
	vec3 screen_color = texture(SCREEN_TEXTURE, UV).rgb;
	COLOR = vec4(quantize(screen_color, ivec2(floor(FRAGCOORD.xy))), 1.0);
}