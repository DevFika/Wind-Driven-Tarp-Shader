@tool
extends Node3D

var previous_rotation: Basis = Basis()

@export_range (0.0, 5.0, 0.01, "or_greater") var wind_intensity: float = 1.0:
	set(new_intensity):
		wind_intensity = new_intensity
		RenderingServer.global_shader_parameter_set("wind_intensity", wind_intensity)

@export_range (0.0, 5.0, 0.01, "or_greater") var wind_speed: float = 1.0:
	set(new_speed):
		wind_speed = new_speed
		RenderingServer.global_shader_parameter_set("wind_speed", wind_speed)
		
func _process(delta: float) -> void:
	if basis.is_equal_approx(previous_rotation):
		return
	
	RenderingServer.global_shader_parameter_set(
		"wind_direction",
		Vector3(basis.z.x, 0.0, basis.z.z).normalized()
	)
	previous_rotation = basis
