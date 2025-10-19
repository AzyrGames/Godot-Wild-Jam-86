extends Node

const SceneManager := preload("uid://c2x646a2anddk")


func instance_node(_file_path: String) -> Node:
	return SceneManager.instance_node(_file_path)



func add_vfx(_packed_scene: PackedScene, _pos: Vector2) -> void:
	if !_packed_scene: return
	var _node: = _packed_scene.instantiate()
	if !is_instance_valid(_node): return
	if _node is GPUParticles2D:
		_node.global_position = _pos + Vector2(0, 10)
		GameManager.game_2d.add_child(_node)
		_node.emitting = true
	



func format_seconds(time : float, use_milliseconds : bool) -> String:
	var minutes := time / 60
	var seconds := fmod(time, 60)
	if not use_milliseconds:
		return "%02d:%02d" % [minutes, seconds]
	var milliseconds := fmod(time, 1) * 1000
	return "%02d:%02d:%03d" % [minutes, seconds, milliseconds]


var _rand_angle : float 
func rand_direction_cirle() -> Vector2:
	_rand_angle = randf() * TAU  # Random angle between 0 and 2π
	return Vector2(cos(_rand_angle), sin(_rand_angle))


func get_rand_pos_circle_range(_origin_pos: Vector2, _range_min: float, _range_max: float) -> Vector2:
	var _rand_direction : Vector2 = rand_direction_cirle()
	var _range_distance : float = randf_range(_range_min, _range_max)
	return _origin_pos + _rand_direction*_range_distance


func get_tick_time() -> float:
	return 1.0 / Engine.physics_ticks_per_second