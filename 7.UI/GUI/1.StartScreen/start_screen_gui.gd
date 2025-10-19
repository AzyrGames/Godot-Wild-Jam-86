extends Control


@export var start_button: Button
@export var setting_button: Button
@export var credit_button: Button
@export var quit_button: Button


func _ready() -> void:
	await get_tree().process_frame
	start_button.grab_focus.call_deferred()
	connect_button()
	get_viewport().gui_focus_changed.connect(func(control):
		if control:
			print(control.name, " has focus")
		else:
			print("nothing has focus")
	)

func connect_button() -> void:
	start_button.pressed.connect(_on_start_button_button_up)
	setting_button.pressed.connect(_on_setting_button_button_up)
	credit_button.pressed.connect(_on_credit_button_button_up)
	quit_button.pressed.connect(_on_quit_button_button_up)
	pass


func _on_start_button_button_up() -> void:
	EventBus.start_game.emit()
	GuiManager.switch_gui_panel(GuiManager.GUIPanel.CLOSED)
	pass


func _on_setting_button_button_up() -> void:
	GuiManager.switch_gui_panel(GuiManager.GUIPanel.SETTING_MENU)
	pass

func _on_quit_button_button_up() -> void:
	EventBus.quit_game.emit()
	pass


func _on_credit_button_button_up() -> void:
	GuiManager.switch_gui_panel(GuiManager.GUIPanel.CREDIT_SCREEN)
	pass # Replace with function body.
