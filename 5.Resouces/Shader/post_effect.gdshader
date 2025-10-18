shader_type canvas_item;
uniform vec2 cam_offset = vec2(0.0, 0.0);

uniform sampler2D tex: filter_nearest;
uniform bool is_active;


void vertex() {
	// Pixel perfect
    if (is_active == true){
	    VERTEX += cam_offset;
    }
}

uniform vec2 resolution = vec2(480, 270);

uniform float scan_line_amount : hint_range(0.0, 1.0) = 0.5;
uniform float warp_amount : hint_range(0.0, 1.0) = 0.05;
uniform float vignette_amount : hint_range(0.0, 1.0) = 0.5; // Contro_valuels the strength of the darkening
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.3; // Controls the size/falloff of the vignette
uniform float grille_amount : hint_range(0.0, 1.0) = 0.05;
uniform float brightness_boost : hint_range(1.0, 2.0) = 1.2;

uniform float bloom_spread = 1;
uniform float bloom_intensity = 2;

// New uniform variables for HSV and Chromatic Aberration
uniform float hue_shift : hint_range(-0.5, 0.5) = 0.0;
uniform float saturation : hint_range(0.0, 2.0) = 1.0;
uniform float value_mult : hint_range(0.0, 2.0) = 1.0;
uniform float aberration_amount : hint_range(0.0, 0.1) = 0.005;

// Helper function to convert RGB to HSV
vec3 rgb_to_hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// Helper function to convert HSV to RGB
vec3 hsv_to_rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
    if (is_active == true){
    // Chromatic Aberration. Samples R, G, and B from offset UVs.
    vec2 center = SCREEN_UV - 0.5;
    float dist = dot(center, center);
    vec2 offset = center * dist * aberration_amount;
    
    vec3 base_color;
    base_color.r = texture(tex, SCREEN_UV + offset).r;
    base_color.g = texture(tex, SCREEN_UV).g;
    base_color.b = texture(tex, SCREEN_UV - offset).b;
    
    // HSV Editor. Adjusts color values after aberration.
    vec3 hsv = rgb_to_hsv(base_color);
    hsv.r = mod(hsv.r + hue_shift, 1.0);
    hsv.g *= saturation;
    hsv.b *= value_mult;
    vec3 processed_color = hsv_to_rgb(hsv);
    
    // CRT Shader. Now operates on the `processed_color`.
    vec2 uv = SCREEN_UV;
    
    vec2 delta = uv - 0.5;
    float warp_factor = dot(delta, delta) * warp_amount;
    uv += delta * warp_factor;
    
    float scanline = sin(uv.y * resolution.y * PI) * 0.5 + 0.5;
    scanline = mix(1.0, scanline, scan_line_amount * 0.5);
    
    float grille = mod(uv.x * resolution.x, 3.0) < 1.5 ? 0.95 : 1.05;
    grille = mix(1.0, grille, grille_amount * 0.5);
    
    vec3 crt_color = processed_color * scanline * grille;
    
    // Modified: Corner Darkening (Vignette)
    // Calculate distance from the center of the screen
    vec2 ndc_uv = SCREEN_UV * 2.0 - 1.0; // Normalized Device Coordinates (-1 to 1)
    float len = length(ndc_uv); // Distance from center
    
    // Apply a power curve to the distance to control the falloff
    // Smoothstep can also be used for a smoother transition
    float vignette_effect = smoothstep(1.0 - vignette_intensity, 1.0, len);
    
    // Mix the color with black based on the vignette effect and amount
    crt_color = mix(crt_color, vec3(0.0), vignette_effect * vignette_amount);
    
    crt_color *= brightness_boost;
    
    // Bloom. This part remains separate as a single-pass solution.
    ivec2 size = textureSize(tex, 0);
    
    float uv_x = SCREEN_UV.x * float(size.x);
    float uv_y = SCREEN_UV.y * float(size.y);
    
    vec4 sum = vec4(0.0);
    for (int n = 0; n < 9; ++n) {
        uv_y = (SCREEN_UV.y * float(size.y)) + float(bloom_spread * float(n - 4));
        vec4 h_sum = vec4(0.0);
        h_sum += texelFetch(tex, ivec2(int(uv_x) - int(4.0 * bloom_spread), int(uv_y)), 0);
        h_sum += texelFetch(tex, ivec2(int(uv_x) - int(3.0 * bloom_spread), int(uv_y)), 0);
        h_sum += texelFetch(tex, ivec2(int(uv_x) - int(2.0 * bloom_spread), int(uv_y)), 0);
        h_sum += texelFetch(tex, ivec2(int(uv_x) - int(bloom_spread), int(uv_y)), 0);
        h_sum += texelFetch(tex, ivec2(int(uv_x), int(uv_y)), 0);
        h_sum += texelFetch(tex, ivec2(int(uv_x) + int(bloom_spread), int(uv_y)), 0);
        h_sum += texelFetch(tex, ivec2(int(uv_x) + int(2.0 * bloom_spread), int(uv_y)), 0);
        h_sum += texelFetch(tex, ivec2(int(uv_x) + int(3.0 * bloom_spread), int(uv_y)), 0);
        h_sum += texelFetch(tex, ivec2(int(uv_x) + int(4.0 * bloom_spread), int(uv_y)), 0);
        sum += h_sum / 9.0;
    }
    vec4 bloom = texture(tex, SCREEN_UV) + ((sum / 9.0) * bloom_intensity);
    COLOR = mix(vec4(crt_color, 1), bloom, 0.6);
    }
}
