shader_type spatial;
render_mode cull_disabled;


uniform sampler2D albedo_texture: source_color;
uniform sampler2D normal_texture: hint_normal;
uniform sampler2D orm_texture;
uniform sampler2D wind_noise_texture;

uniform float texture_uv_scale = 1.0;

// Wind Globals
global uniform vec3 wind_direction;
global uniform float wind_intensity;
global uniform float wind_speed;

varying vec2 texture_uv;

float get_position_sum(vec3 world_position) {
	return world_position.x + world_position.y + world_position.z;
}

void vertex() {
	texture_uv = UV * texture_uv_scale;
	
	float position_sum = get_position_sum(NODE_POSITION_WORLD);
	
	vec3 model_front_direction = vec3(1.0, 0.0, 0.0);
	vec3 model_side_direction = vec3(0.0, 0.0, 1.0);
	
	float vertex_color_mask = COLOR.r;
	
	mat3 inv_model_matrix = inverse(mat3(MODEL_MATRIX));
	vec3 wind_local_direction = normalize(inv_model_matrix * wind_direction);
	
	float dot_product = dot(model_front_direction, wind_local_direction);
	float side_dot = dot(model_side_direction, wind_local_direction);
	
	float strength = abs(dot_product);
	float push_strength = clamp(strength, 0.01, 1.0);
	float noise_strength = clamp(strength, 0.5, 1.0);
	
	float scroll_direction = -1.0 * sign(side_dot);
	float scroll_speed = wind_speed;
	
	float wind_uv_scale = 0.1;
	float wind_object_offset = position_sum * 0.2;
	
	vec2 wind_uv = vec2(
		VERTEX.z * wind_uv_scale + TIME * scroll_speed * scroll_direction + wind_object_offset,
		VERTEX.y * wind_uv_scale
	);
	
	float wind_noise = texture(wind_noise_texture, wind_uv).r;
	
	// Unpack wind noise, from 0 - 1 range, to -1 1 range
	wind_noise = 2.0 * wind_noise - 1.0;
	
	VERTEX += wind_local_direction * wind_intensity * push_strength * vertex_color_mask;
	VERTEX.x += wind_noise * 0.5 * wind_intensity * noise_strength * vertex_color_mask;
}

void fragment() {
	// Sample textures
	vec3 albedo = texture(albedo_texture, texture_uv).rgb;
	vec3 normal = texture(normal_texture, texture_uv).rgb;
	vec3 orm = texture(orm_texture, texture_uv).rgb;
	
	// Unpack ORM texture, (Ambient Occlusion, Roughness, Metallic)
	float ao = orm.r;
	float roughness = orm.g;
	float metallic = orm.b;
	
	
	ALBEDO = albedo;
	//ALBEDO = COLOR.rgb;
	NORMAL_MAP = normal;
	AO = ao;
	ROUGHNESS = roughness;
	METALLIC = metallic;
}









