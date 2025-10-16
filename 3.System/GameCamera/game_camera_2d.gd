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
	pass


func follow_target() -> void:
	if !tween_complete: return
	if follow_target_node:
		global_position = global_position.lerp(follow_target_node.global_position, 0.15)
	pass

func _on_character_switched(_character_type: GameData.CharacterType) -> void:
	follow_target_node = GameData.entity_character_node.get(_character_type)
	tween_to_new_character()
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
