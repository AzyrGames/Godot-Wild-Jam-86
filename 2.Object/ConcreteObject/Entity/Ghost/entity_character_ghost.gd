extends EntityCharacter2D
class_name EntityCharacterGhost2D

@export var active: bool = false
@export var is_following: bool = true
@export var move_speed: float
@export var move_direction: Vector2

var _last_move_direction: Vector2

var is_mask := false

func _ready() -> void:
	GameData.entity_character_node.get_or_add(GameData.CharacterType.GHOST, self)
	EventBus.mask_created.connect(func(_v): is_mask = true)
	EventBus.mask_destroyed.connect(func(): is_mask = false)
	EventBus.character_switched.connect(_on_character_switched)


func _physics_process(_delta: float) -> void:
	visible = !is_mask
	if !active:
		return

	if !is_mask and Input.is_action_just_pressed(&"move_jump"):
		if GameData.mask_tracker != self:
			set_marker()
		else:
			trigger_mask()
	if !is_mask:
		move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	else:
		move_direction = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	visible = !is_mask
	if !active:
		return

	if !is_mask and Input.is_action_just_pressed(&"move_jump"):
		if GameData.mask_tracker != self:
			set_marker()
		else:
			trigger_mask()
	if !is_mask:
		move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	else:
		move_direction = Vector2.ZERO
	if _last_move_direction != move_direction:
		_last_move_direction = move_direction
		calculate_velocity()
	move_and_slide()

func _on_character_switched(char: GameData.CharacterType) -> void:
	if char == GameData.CharacterType.GHOST and is_mask:
		EventBus.mask_destroyed.emit()
	pass

# var _

func follow_player() -> void:
	var _characer_target_pos := GameManager.game_character.global_position + Vector2(0, -60)
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
