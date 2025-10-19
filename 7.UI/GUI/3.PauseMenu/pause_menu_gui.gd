extends Control

@onready var resume_button := %ResumeButton as Button
@onready var respawn_button := %Respawn as Button
@onready var setting_button := %SettingButton as Button
@onready var go_to_start_screen_button := %GoToStartScreenButton as Button

@onready var quit_warning := %QuitWarning as PanelContainer
@onready var cancel_quit := %CancelQuit as Button
@onready var confirm_quit := %ConfirmQuit as Button

func _ready() -> void:
	resume_button.grab_focus()
	quit_warning.visible = false
	visibility_changed.connect(resume_button.grab_focus)
	quit_warning.visibility_changed.connect(func():
		cancel_quit.grab_focus()
		var s = quit_warning.visible
		resume_button.disabled = s
		setting_button.disabled = s
		go_to_start_screen_button.disabled = s
		respawn_button.disabled = s
	)
	pass


func _on_resume_button_button_up() -> void:
	GuiManager.switch_gui_panel(GuiManager.GUIPanel.CLOSED)
	GameManager.resume_game()
	pass

func _on_setting_button_button_up() -> void:
	GuiManager.switch_gui_panel(GuiManager.GUIPanel.SETTING_MENU)
	pass


func _on_go_to_start_screen_button_button_up() -> void:
	quit_warning.visible = true


func _on_exit_game_button_button_up() -> void:
	get_tree().quit()
	pass


func _on_respawn_pressed() -> void:
	GameManager.game_2d.respawn_character()
	GuiManager.switch_gui_panel(GuiManager.GUIPanel.CLOSED)
	GameManager.resume_game()
	pass # Replace with function body.


func _on_cancel_quit_pressed() -> void:
	quit_warning.visible = false


func _on_confirm_quit_pressed() -> void:
	EventBus.exit_game.emit()
	GuiManager.switch_gui_panel(GuiManager.GUIPanel.START_SCREEN)
	quit_warning.visible = false
	pass
