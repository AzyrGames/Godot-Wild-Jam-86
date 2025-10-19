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
			if asp_checkpoint:
				asp_checkpoint.play()
		is_active = value

@export var asp_checkpoint: AudioStreamPlayer2D

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
	triggered.connect(_on_triggered)
	EventBus.check_point_entered.connect(func():
		if GameManager.current_checkpoint != self:
			is_active = false
	)
	pass


func _on_triggered() -> void:
	if GameManager.current_checkpoint and GameManager.current_checkpoint != self:
		GameManager.current_checkpoint.is_active = false
	GameManager.current_checkpoint = self
	is_active = true
	EventBus.check_point_entered.emit()
	pass # Replace with function body.
