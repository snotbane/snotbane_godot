shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx, depth_test_disabled, unshaded;

uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
	vec3 color = texture(screen_texture, SCREEN_UV).rgb;


	vec3 c = vec3(color.xyz);
	float max1 = max(c.r, c.g);
	float max2 = max(max1, c.b);
	color = vec3(max2, max2, max2);

	ALBEDO = floor((1.0 - color) * 4.0) / 4.0;
}
