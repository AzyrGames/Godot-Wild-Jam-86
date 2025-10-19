extends Node2D
class_name Game2D

@export var current_game_map: Map2D
@export var asp_level_clear: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Console.unregister_command("change_map")
	Console.unregister_command("reset_map")
	Console.register_command(command_change_map, "change_map")
	Console.add_alias("map", "change_map")
	Console.register_command(reset_game_map, "reset_map")
	Console.add_alias("restart", "reset_map")
	Console.register_command(switch_checkpoint, "goto_checkpoint")
	Console.add_alias("chkpt", "goto_checkpoint")

	GameManager.game_2d = self
	connect_event_bus()
	reset_game_map()
	pass # Replace with function body.

func command_change_map(mapname: String) -> void:
	print("Command to change map received, switching to ", GameData.MapList.get("MAP_" + mapname))
	request_and_load_map(GameData.MapList.get("MAP_" + mapname))

func switch_checkpoint(checkpoint: String) -> void:
	if !GameManager.checkpoint_list.has(checkpoint):
		printerr("Checkpoint does not exist")
		Console.print_line("Invalid checkpoint `" + checkpoint + "`")
		Console.print_line("Valid checkpoints: ")
		for chkpt in GameManager.checkpoint_list.keys():
			Console.print_line(chkpt)
		return

	print("Jumping to checkpoint ", checkpoint)
	GameManager.current_checkpoint = GameManager.checkpoint_list.get(checkpoint)
	respawn_character(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_game_map_request()
	pass


func connect_event_bus() -> void:
	EventBus.area_triggered.connect(_on_area_triggered)
	EventBus.switch_map.connect(request_and_load_map)
	EventBus.preload_map.connect(request_game_map)
	EventBus.game_map_changed.connect(reset_game_map)
	pass



func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("force_death"):
		respawn_character()
	pass


func respawn_character(force_ghost := false) -> void:
	GameManager.game_character.global_position = GameManager.current_checkpoint.character_respawn_point.global_position
	if GameData.mask_tracker != GameManager.game_ghost or force_ghost:
		GameManager.game_ghost.global_position = GameManager.current_checkpoint.character_respawn_point.global_position + Vector2(-24.0, -30.0)
	pass



func _on_area_triggered(_trigger_name: String) -> void:
	if _trigger_name == "death_zone":
		respawn_character()
	pass

func reset_game_map() -> void:
	var _check_point_name :String= GameData.map_default_checkpoint.get(_request_map)
	if !GameManager.checkpoint_list.has(_check_point_name):
		printerr("No map")
	GameManager.current_checkpoint = GameManager.checkpoint_list.get(_check_point_name)
	respawn_character(true)
	if GameData.mask_tracker != null:
		EventBus.mask_track_abort.emit()
	if GameManager.current_mask.has_area():
		EventBus.mask_destroyed.emit()
	GameManager.game_camera.snap_to_target(true)
	pass


var _request_game_map_path: String
var _request_map: GameData.MapList
var _load_request_progress: Array = [0.0]
# var _is_map_request: bool = false

func switch_map() -> void:
	pass


func change_game_map_to(_game_map: Map2D) -> bool:
	print("Changing map to ", _game_map.name)
	if !_game_map: return false
	if current_game_map:
		current_game_map.queue_free()
	GameManager.game_character.global_position = Vector2(10000, 10000)
	GameManager.checkpoint_list.clear()
	add_child(_game_map)
	current_game_map = _game_map
	EventBus.game_map_changed.emit()
	if _request_map != GameData.MapList.MAP_1:
		if asp_level_clear:
			asp_level_clear.play()
	return true


func request_game_map(_target_map: GameData.MapList) -> void:
	if !GameData.map_path.has(_target_map):
		print_debug(GameData.map_path, " not found")
		return
	ResourceLoader.load_threaded_request(_request_game_map_path)

func request_and_load_map(target_map: GameData.MapList) -> void:
	_request_map = target_map
	_request_game_map_path = GameData.map_path.get(target_map)
	request_game_map(target_map)


func update_game_map_request() -> void:
	if _request_game_map_path == "": return
	var _request_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(_request_game_map_path, _load_request_progress)
	_check_load_request_status(_request_status)
	pass


func _check_load_request_status(_request_status: ResourceLoader.ThreadLoadStatus) -> void:
	match _request_status:
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
			_request_game_map_path = ""
			print("Map request Invalid")
			pass
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			pass
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			_request_game_map_path = ""
			print("Map request failed")
			Console.print_line("Error: Map request failed")
			pass
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			var _packed_scene: PackedScene = ResourceLoader.load_threaded_get(_request_game_map_path)
			_request_game_map_path = ""
			# _request_map =
			if !_packed_scene:
				print_debug(_packed_scene, " is invalid")
				return
			var _game_map_node: Map2D = _packed_scene.instantiate()
			if !_game_map_node is Map2D:
				print_debug(_game_map_node, " is not game map")
				return

			if !change_game_map_to(_game_map_node):
				print_debug(_game_map_node, " Map transition Failed")
				return
			pass
	pass
