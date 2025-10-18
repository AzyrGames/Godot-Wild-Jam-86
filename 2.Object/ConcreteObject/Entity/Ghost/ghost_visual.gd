extends Line2D

var _last_frame_position: Vector2

var _point_velocity: PackedVector2Array = []

func _ready() -> void:
	_last_frame_position = global_position
	_point_velocity.resize(get_point_count())

func _process(delta: float) -> void:
	var offset := global_position - _last_frame_position
	
	for p_idx in get_point_count():
		set_point_position(p_idx, get_point_position(p_idx) - offset)
		if p_idx == 0:
			var parent_pos := Vector2.ZERO
			var new_pos := get_point_position(p_idx) + (_point_velocity[p_idx] * delta)
			new_pos = parent_pos + (new_pos - parent_pos).limit_length(7.0)
			var dir_to_parent := (parent_pos - new_pos).normalized()
			var mag_to_parent := (parent_pos - new_pos).length()
			var move_mag := maxf(mag_to_parent - 1.0, 0.0)
			_point_velocity[p_idx] += dir_to_parent * move_mag * delta * 30.0
			_point_velocity[p_idx] *= 0.97
			set_point_position(p_idx, new_pos)
		else:
			var parent_pos := get_point_position(p_idx - 1)
			var new_pos := get_point_position(p_idx) + (_point_velocity[p_idx] * delta)
			new_pos = parent_pos + (new_pos - parent_pos).limit_length(4.0)
			_point_velocity[p_idx] = (new_pos - get_point_position(p_idx)) / delta * 0.92
			set_point_position(p_idx, new_pos)
	$Face.play()
	$Face.position = get_point_position(0)
	
	
	_last_frame_position = global_position
