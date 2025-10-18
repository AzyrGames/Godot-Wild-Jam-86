extends EntityCharacter2D
class_name EntityCharacterGhost2D

@export var active: bool = false
@export var is_following: bool = true
@export var move_speed: float
@export var move_direction: Vector2

var _last_move_direction: Vector2


func _ready() -> void:
	GameData.entity_character_node.get_or_add(GameData.CharacterType.GHOST, self)


func _physics_process(delta: float) -> void:
	if !active and is_following:
		follow_player()
	if _last_move_direction != move_direction:
		_last_move_direction = move_direction
		calculate_velocity()
	move_and_slide()
	pass


func _input(event: InputEvent) -> void:
	if !active: return
	if event is InputEventKey:
		move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down", )
		if Input.is_action_just_pressed("move_jump"):
			trigger_mask()
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
	print("yes")
	EventBus.mask_triggered.emit(global_position)
	pass


func set_marker() -> void:
	pass


func clear_marker() -> void:
	pass
