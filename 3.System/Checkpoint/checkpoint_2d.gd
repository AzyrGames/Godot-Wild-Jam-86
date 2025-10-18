extends TriggerArea2D
class_name Checkpoint2D

@export var check_point_name: String

@export var character_respawn_point: CharacterRespawnPoint
@export var collision_shape: CollisionShape2D
@export var animation_player: AnimationPlayer

@export var is_active: bool = false:
	set(value):
		if value != is_active:
			print("updating checkpoint ", name, " to ", value)
			$AnimationPlayer.play(&"get_checkpoint" if value == true else &"RESET")
		is_active = value

func _ready() -> void:
	super()
	# GameData.map_default_checkpoint
	if GameManager.checkpoint_list.has(check_point_name):
		GameManager.checkpoint_list.set(check_point_name, self)
	else:
		GameManager.checkpoint_list.get_or_add(check_point_name, self)
	pass


func _input(event: InputEvent) -> void:
	pass

func connect_signal() -> void:
	super()
	body_shape_entered.connect(_on_body_shape_entered)
	body_shape_exited.connect(_on_body_shape_exited)
	EventBus.check_point_entered.connect(func(entered):
		if not entered:
			return
		if GameManager.current_checkpoint != self:
			is_active = false
	)
	pass


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if GameManager.current_checkpoint and GameManager.current_checkpoint != self:
		GameManager.current_checkpoint.is_active = false
	GameManager.current_checkpoint = self
	is_active = true
	EventBus.check_point_entered.emit(true)
	pass # Replace with function body.


func _on_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	EventBus.check_point_entered.emit(false)
	pass # Replace with function body.
