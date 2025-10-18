extends EntityCharacter2D
class_name EntityCharacterGhost2D

@export var active: bool = false:
	set(value):
		active = value

@export var is_following: bool = true
@export var move_speed: float
@export var move_direction: Vector2

var is_mask := true

var _last_move_direction: Vector2
var _time := 0.0

func _ready() -> void:
	GameData.entity_character_node.get_or_add(GameData.CharacterType.GHOST, self)
	# EventBus.mask_created.connect(func(_v): is_mask = true)
	# EventBus.mask_destroyed.connect(func(): is_mask = false)
	EventBus.character_switched.connect(_on_character_switched)


func _physics_process(_delta: float) -> void:
	_time += _delta
	if active and Input.is_action_just_pressed(&"move_jump"):
		if !GameData.mask_tracker:
			set_marker()
		else:
			clear_marker()

	if active:
		move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	elif !GameData.mask_tracker:
		follow_player()

	if _last_move_direction != move_direction:
		_last_move_direction = move_direction
		calculate_velocity()
	move_and_slide()


func _on_character_switched(char: GameData.CharacterType) -> void:
	if !char == GameData.CharacterType.GHOST: return
	active = !active
	pass

# var _

func follow_player() -> void:
	var _characer_target_pos := GameManager.game_character.global_position + Vector2(sin(_time) * 30.0, cos(_time / 2.0) * 15.0)
	if cos(_time) > 0.0:
		z_index = 1
	else:
		z_index = 0
	if global_position.distance_to(_characer_target_pos) > 5:
		move_direction = global_position.direction_to(_characer_target_pos)
	else:
		move_direction = Vector2.ZERO
	pass

func calculate_velocity() -> void:
	velocity = move_direction * move_speed
	pass


func trigger_mask() -> void:
	EventBus.mask_track_finished.emit(global_position)
	GameData.mask_tracker = null
	EventBus.character_switched.emit(GameData.CharacterType.PLATFORMER)
	pass


func set_marker() -> void:
	EventBus.mask_point_set.emit(global_position)
	GameData.mask_tracker = self
	pass


func clear_marker() -> void:
	GameData.mask_tracker = null
	EventBus.mask_track_abort.emit()
