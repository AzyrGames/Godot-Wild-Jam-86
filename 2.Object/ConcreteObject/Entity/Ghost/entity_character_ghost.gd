extends EntityCharacter2D
class_name EntityCharacterGhost2D

@export var active: bool = false:
	set(value):
		active = value
		set_warn_oversized(_state == GameData.GhostState.OVERSIZE)
		if asp_ghost_hover:
			if !asp_ghost_hover.playing:
				asp_ghost_hover.playing = true
			if active:
				asp_ghost_hover.set("parameters/switch_to_clip", "sfx_ghost_hover")
			else:
				asp_ghost_hover.set("parameters/switch_to_clip", "sfx_ghost_hover_end")

@export var is_following: bool = true
@export var move_speed: float
@export var move_direction: Vector2

@export var body: Line2D

@export var asp_ghost_hover: AudioStreamPlayer2D

var is_mask := true

var _time := 0.0
var _state := GameData.GhostState.IDLE

var _statechange_locked := false

func _ready() -> void:
	if GameData.entity_character_node.has(GameData.CharacterType.GHOST):
		GameData.entity_character_node.set(GameData.CharacterType.GHOST, self)
	else:
		GameData.entity_character_node.get_or_add(GameData.CharacterType.GHOST, self)
	GameManager.game_ghost = self
	# EventBus.mask_created.connect(func(_v): is_mask = true)
	# EventBus.mask_destroyed.connect(func(): is_mask = false)
	EventBus.character_switched.connect(_on_character_switched)
	EventBus.mask_track_abort.connect(_on_mask_abort)


func _physics_process(_delta: float) -> void:
	_time += _delta
	if active and not _statechange_locked and Input.is_action_just_pressed(&"move_jump"):
		if !GameData.mask_tracker:
			set_marker()
		else:
			finish_mask()
		_statechange_locked = true
		create_tween().tween_callback(func(): _statechange_locked = false).set_delay(0.1)

	if active:
		move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	elif !GameData.mask_tracker:
		follow_player()
	else:
		move_direction = Vector2.ZERO

				# asp_ghost_hover.finished.connect(_asp_ghost_finished)

	calculate_velocity()
	move_and_slide()


# func _asp_ghost_finished() -> void:
# 	asp_ghost_hover.playing = false


func _on_character_switched(_character: GameData.CharacterType) -> void:
	if !_character == GameData.CharacterType.GHOST: return
	active = !active
	pass

func _on_mask_abort() -> void:
	GameData.mask_tracker = null
	set_warn_oversized(false)

# var _

func follow_player() -> void:
	var _characer_target_pos := GameManager.game_character.global_position + Vector2(sin(_time) * 30.0, cos(_time / 2.0) * 15.0)
	if cos(_time) > 0.0:
		z_index = 2
	else:
		z_index = 1
	if global_position.distance_to(_characer_target_pos) > 5:
		move_direction = global_position.direction_to(_characer_target_pos)
	else:
		move_direction = Vector2.ZERO
	pass

func calculate_velocity() -> void:
	velocity = move_direction * move_speed * (1.0 if _state != GameData.GhostState.OVERSIZE else 0.5)
	pass


func finish_mask() -> void:
	EventBus.mask_track_finished.emit(global_position)
	GameData.mask_tracker = null
	set_warn_oversized(false)
	pass


func set_marker() -> void:
	EventBus.mask_point_set.emit(global_position)
	GameData.mask_tracker = self
	pass


func clear_marker() -> void:
	EventBus.mask_track_abort.emit()

func set_ghost_state(state: GameData.GhostState) -> void:
	body.set_ghost_state(state)
	_state = state

func set_warn_oversized(oversize: bool) -> void:
	if oversize:
		set_ghost_state(GameData.GhostState.OVERSIZE)
	elif GameData.mask_tracker == self:
		set_ghost_state(GameData.GhostState.MASKING)
	elif active:
		set_ghost_state(GameData.GhostState.ACTIVE)
	else:
		set_ghost_state(GameData.GhostState.IDLE)
