extends Node2D
class_name Main2D

const GAME_PATH: String = "uid://bw3votfvu4bw7"

@export var sub_viewport_container: SubViewportContainer
@export var sub_viewport: SubViewport
@export var game_timer: Timer
@export var asp_music: AudioStreamPlayer

@export var cross_hair : Sprite2D

var game_2d: Game2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.main_2d = self
	GuiManager.switch_gui_panel(GuiManager.GUIPanel.START_SCREEN)
	connect_event_bus()

	pass # Replace with function body.



func connect_event_bus() -> void:
	pass


func start_music() -> void:
	if asp_music:
		pass
	pass



func start_game() -> bool:
	clear_game()
	return add_game()



func clear_game() -> void:
	if game_2d:
		game_2d.queue_free()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass



func add_game() -> bool:
	game_2d = get_game_node()
	if !game_2d:
		print("Not game")
		return false
	if sub_viewport:
		sub_viewport.add_child(game_2d)
	else:
		add_child(game_2d)
	return true


func get_game_node() -> Game2D:
	var _game_node : Node = Utils.instance_node(GAME_PATH)
	if !_game_node is Game2D: return
	return _game_node


func set_subpixel_shader(_value: Vector2) -> void:
	# print(_value)
	sub_viewport_container.material.set_shader_parameter("cam_offset", _value)
	# print(sub_viewport_container.get_instance_shader_parameter("cam_offset"))
	pass
