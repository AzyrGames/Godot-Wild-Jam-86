extends Control


# Called when the node enters the scene tree for the first time.


@onready var time_label: Label = %TimeLabel
# @onready var continue_label: Label = %ContinueLabel

func _ready() -> void:
	pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	time_label.text = "Finish Time: " + Utils.format_seconds(GameManager.main_2d.GAME_TIME_LIMIT - GameManager.main_2d.game_timer.time_left, true)
	# continue_label.text = "Continue: " + str(Global.continue_time)


func _on_new_game_button_pressed() -> void:
	# GameManager.clear_game()
	GameManager.start_game()
	GuiManager.switch_gui_panel(GuiManager.GUIPanel.CLOSED)

	# GuiManager.switch_gui_panel(GuiManager.GUIPanel.DIFFICULTY_SELECTION)
	pass # Replace with function body.

func _on_back_button_pressed() -> void:
	GuiManager.switch_gui_panel(GuiManager.GUIPanel.START_SCREEN)
	pass # Replace with function body.
