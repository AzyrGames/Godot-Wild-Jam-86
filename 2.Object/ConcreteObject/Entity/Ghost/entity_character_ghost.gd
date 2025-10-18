extends EntityCharacter2D
class_name EntityCharacterGhost2D

@export var active: bool = false

@export var move_speed: float
@export var move_direction: Vector2

var _last_move_direction: Vector2


func _ready() -> void:
	GameData.entity_character_node.get_or_add(GameData.CharacterType.GHOST, self)


func _physics_process(delta: float) -> void:
	if !active: return
	if _last_move_direction != move_direction:
		calculate_velocity()
		_last_move_direction = move_direction
	move_and_slide()
	pass


func _input(event: InputEvent) -> void:
	if !active: return
	if event is InputEventKey:
		move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down", )
		if Input.is_action_just_pressed("move_jump"):
			trigger_mask()
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
