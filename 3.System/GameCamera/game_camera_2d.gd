extends Camera2D
class_name GameCamera2D


@export var follow_target_node: Node2D
@export var horizontal_death_zone: Vector2


var tween_complete: bool = true


func _ready() -> void:
	GameManager.game_camera = self
	connect_event_bus()


func _physics_process(delta: float) -> void:
	follow_target()
	pass


func connect_event_bus() -> void:
	EventBus.character_switched.connect(_on_character_switched)
	EventBus.change_camera_constraint.connect(change_camera_constraint)
	pass


func follow_target() -> void:
	if !tween_complete: return
	if follow_target_node:
		global_position = global_position.lerp(follow_target_node.global_position, 0.15)
	pass


var camera_tween : Tween

func tween_to_new_character() -> void:
	camera_tween = create_tween()
	tween_complete = false
	camera_tween.tween_property(self, "global_position", follow_target_node.global_position, 0.3).set_trans(Tween.TRANS_SINE)
	camera_tween.tween_callback(_on_camera_tween_done)
	pass

func _on_camera_tween_done() -> void:
	tween_complete = true



func _on_character_switched(_character_type: GameData.CharacterType) -> void:
	follow_target_node = GameData.entity_character_node.get(_character_type)
	tween_to_new_character()
	pass


func change_camera_constraint(_constraint_camera: Camera2D) -> void:
	print("change camera contraint")
	# limit_left = _constraint_camera.limit_left
	# limit_right = _constraint_camera.limit_right
	# limit_bottom = _constraint_camera.limit_bottom
	# limit_top = _constraint_camera.limit_top
	# var tween := create_tween()

	limit_left = _constraint_camera.limit_left
	limit_right = _constraint_camera.limit_right
	limit_bottom = _constraint_camera.limit_bottom
	limit_top = _constraint_camera.limit_top
	pass

func snap_to_target() -> void:
	#limit_left = -100000
	#limit_right = 100000
	#limit_bottom = 100000
	#limit_top = -10000
	if camera_tween:
		camera_tween.stop()
	global_position = follow_target_node.global_position
	reset_smoothing()
