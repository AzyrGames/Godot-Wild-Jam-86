extends Node2D


@export var character_platformer: EntityCharacterPlatformer2D
@export var character_ghost: EntityCharacterGhost2D

var is_character_platformer: bool = true


var switch_cooldown: Timer

func _ready() -> void:
	create_switch_cooldown()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("switch_character"):
		switch_character()
	pass


func switch_character() ->void:
	if !switch_cooldown.is_stopped(): return
	if is_character_platformer:
		character_platformer.active = false
		character_ghost.active = true

		EventBus.character_switched.emit(GameData.CharacterType.GHOST)
	else:
		character_platformer.active = true
		character_ghost.active = false
		EventBus.character_switched.emit(GameData.CharacterType.PLATFORMER)
	is_character_platformer = !is_character_platformer
	switch_cooldown.start()
	pass



func create_switch_cooldown() -> void:
	switch_cooldown = Timer.new()
	switch_cooldown.autostart = false
	switch_cooldown.one_shot = true
	switch_cooldown.wait_time = 0.3
	add_child(switch_cooldown)
