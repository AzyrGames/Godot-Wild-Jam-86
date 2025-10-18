extends Node2D
class_name Game2D



@export var asp_projectile_destroy: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.game_2d = self
	connect_event_bus()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func connect_event_bus() -> void:
	pass



func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("force_death"):
		respawn_character()
	pass


func respawn_character() -> void:
	GameManager.game_character.global_position = GameManager.current_checkpoint.character_respawn_point.global_position
	pass
