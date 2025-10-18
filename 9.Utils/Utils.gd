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