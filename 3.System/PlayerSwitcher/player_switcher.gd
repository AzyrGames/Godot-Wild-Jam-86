extends Node2D


@export var character_platformer: EntityCharacterPlatformer2D
@export var character_ghost: EntityCharacterGhost2D



var is_character_platformer: bool = true


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("switch_character"):
		switch_character()
	pass


func switch_character() ->void:
	if is_character_platformer:
		character_platformer.active = false
		character_ghost.active = true

		EventBus.character_switched.emit(GameData.CharacterType.GHOST)
	else:
		character_platformer.active = true
		character_ghost.active = false
		EventBus.character_switched.emit(GameData.CharacterType.PLATFORMER)

	is_character_platformer = !is_character_platformer
	pass
