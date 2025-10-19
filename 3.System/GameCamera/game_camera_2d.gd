extends Camera2D
class_name GameCamera2D


@export var follow_target_node: Node2D
@export var horizontal_death_zone: Vector2


var tween_complete: bool = true


func _ready() -> void:
	GameManager.game_camera = self
	connect_event_bus()
	real_position = global_position

var real_position: Vector2

func _physics_process(delta: float) -> void:
	global_position = real_position
	follow_target()
	real_position = global_position
	global_position = snapped(global_position, Vector2.ONE)
	GameManager.main_2d.set_subpixel_shader(real_position - global_position)
	# GameManager.main_2d.set_subpixel_shader(global_position - real_position)


	# GameManager.main_2d.set_subpixel_shader(real_position.snapped(Vector2.ONE) - real_position)
	# print(global_position)
	pass


func connect_event_bus() -> void:
	EventBus.character_switched.connect(_on_character_switched)
	EventBus.change_camera_constraint.connect(change_camera_constraint)
	pass


func follow_target() -> void:
	if !tween_complete: return
	if follow_target_node:
		global_position = follow_target_node.global_position
	pass


var camera_tween : Tween

func tween_to_new_character() -> void:
	if camera_tween:
		camera_tween.kill()
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

func snap_to_target(skip_limits := false) -> void:
	if skip_limits:
		limit_left = -100000
		limit_right = 100000
		limit_bottom = 100000
		limit_top = -10000
	if camera_tween:
		camera_tween.kill()
	global_position = follow_target_node.global_position
	reset_smoothing()
