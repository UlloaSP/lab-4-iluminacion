shader_type spatial;
render_mode cull_back;

uniform vec4 base_color : source_color = vec4(0.78, 0.78, 0.82, 1.0);
uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform bool use_texture = false;
uniform float ambient_strength : hint_range(0.0, 1.0) = 0.04;
uniform float shininess : hint_range(1.0, 256.0) = 16.0;
uniform float specular_strength : hint_range(0.0, 2.0) = 0.2;

void fragment() {
	vec3 color = base_color.rgb;
	if (use_texture) {
		color *= texture(albedo_texture, UV).rgb;
	}
	ALBEDO = color;
	ALPHA = base_color.a;
	EMISSION = color * ambient_strength;
}

void light() {
	vec3 N = normalize(NORMAL);
	vec3 L = normalize(LIGHT);
	vec3 V = normalize(VIEW);
	vec3 R = reflect(-L, N);

	float diff = max(dot(N, L), 0.0);
	float spec = 0.0;

	if (diff > 0.0) {
		spec = pow(max(dot(V, R), 0.0), shininess) * specular_strength;
	}

	DIFFUSE_LIGHT += diff * ALBEDO * LIGHT_COLOR * ATTENUATION;
	SPECULAR_LIGHT += spec * LIGHT_COLOR * ATTENUATION;
}
