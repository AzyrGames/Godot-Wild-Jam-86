extends Control

# @onready var staminia_bar: TextureProgressBar = %StaminaProgessBar

@onready var fpslabel: Label = $FPSLabel
@onready var game_time_label : Label = %GameTimeLabel

func _ready() -> void:
	visible = false


func _physics_process(delta: float) -> void:
	game_time_label.text = Utils.format_seconds(GameManager.main_2d.GAME_TIME_LIMIT - GameManager.main_2d.game_timer.time_left, true)
	fpslabel.text = "FPS: " + str(Engine.get_frames_per_second())


func setup_hud() -> void:
	pass

func health_bar() -> void:
	pass
