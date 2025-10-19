shader_type canvas_item;
uniform sampler2D screentex: hint_screen_texture, filter_nearest;

uniform sampler2D color_lut: filter_linear;

vec2 snapped(vec2 original, vec2 snap_size) {
	return floor(original / snap_size) * snap_size;
}

void fragment() {
	vec2 uv = SCREEN_UV;
	uv.x += sin(uv.y * 90.0 + TIME) * 0.00125;
	vec4 color = texture(screentex, snapped(uv, SCREEN_PIXEL_SIZE) + SCREEN_PIXEL_SIZE * 0.5);
	vec2 lut_uv = color.rg;
	lut_uv.r = lut_uv.r / 16.0;
	float lut_b_uv = floor(color.b * 16.1) / 16.1;
	float offset = color.b - lut_b_uv;
	COLOR = mix(
		texture(color_lut, lut_uv + vec2(lut_b_uv, 0.0)),
		texture(color_lut, lut_uv + vec2(lut_b_uv + (1.0 / 16.0), 0.0)),
		offset);
	//COLOR.rgb = vec3(offset);
}