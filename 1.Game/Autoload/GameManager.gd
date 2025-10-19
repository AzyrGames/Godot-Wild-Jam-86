extends Node


# Game state variables
var is_game_active: bool = false
var is_game_paused: bool = false
var current_game_state: Dictionary = {}


var main_2d: Main2D
var game_2d: Game2D

var game_camera: GameCamera2D
var game_character: EntityCharacterPlatformer2D
var game_ghost: EntityCharacterGhost2D
var current_checkpoint: Checkpoint2D

var checkpoint_list : Dictionary[String, Checkpoint2D]

var current_mask: Rect2i

# Configuration variables
@export var default_time_scale: float = 1.0
@export var freeze_duration_limit: float = 5.0
@export var min_time_scale: float = 0.1

func _ready() -> void:
	connect_event_bus()
	initialize_game_manager()


func connect_event_bus() -> void:
	EventBus.start_game.connect(start_game)
	EventBus.exit_game.connect(exit_game)
	EventBus.quit_game.connect(quit_game)
	EventBus.mask_created.connect(func(new_mask):
		current_mask = new_mask
	)
	EventBus.mask_destroyed.connect(func():
		current_mask = Rect2i(0, 0, 0, 0)
	)
	EventBus.area_triggered.connect(_on_area_triggered)
	pass


# Core initialization
func initialize_game_manager() -> void:
	pass

# Game setup and configuration
func configure_game_settings() -> void:
	pass


func start_game() -> void:
	is_game_active = main_2d.start_game()
	GuiManager.active_gui_panel.get(GuiManager.GUIPanel.HUD).visible = true

	pass


func resume_game() -> void:
	set_game_paused(false)
	is_game_active = true
	pass


# Reset game to initial state
func reset_game() -> void:
	pass


func game_victory() -> void:
	clear_game()
	main_2d.game_timer.paused = true
	GuiManager.switch_gui_panel(GuiManager.GUIPanel.VICTORY_SCREEN)
	pass


func exit_game() -> void:
	clear_game()
	is_game_active = false
	pass


func quit_game() -> void:
	clear_game()
	get_tree().quit()
	pass


func clear_game() -> void:
	GuiManager.active_gui_panel.get(GuiManager.GUIPanel.HUD).visible = false
	main_2d.clear_game()
	set_game_paused(false)


# Load saved game state
func load_game_state() -> bool:
	return false


# Save current game state
func save_game_state() -> void:
	pass


# Handle character death
func handle_character_death() -> void:
	pass


# Pause/unpause game
func set_game_paused(pause: bool) -> void:
	is_game_paused = pause
	get_tree().paused = pause
	EventBus.game_paused.emit(pause)
	pass


# Toggle pause state
func toggle_pause() -> void:
	set_game_paused(!is_game_paused)
	pass


# Freeze frame effect with safety checks
func freeze_frame(time_scale: float, duration: float) -> void:
	if time_scale < min_time_scale or time_scale > 1.0:
		push_warning("Time scale must be between ", min_time_scale, " and 1.0")
		return
	if duration < 0 or duration > freeze_duration_limit:
		push_warning("Duration must be between 0 and ", freeze_duration_limit, " seconds")
		return

	EventBus.game_frozen.emit(time_scale, duration)
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale, false).timeout
	Engine.time_scale = default_time_scale
	EventBus.game_unfrozen.emit()



func _on_area_triggered(_trigger_name: String) -> void:
	if _trigger_name == "Victory":
		game_victory()
	pass
