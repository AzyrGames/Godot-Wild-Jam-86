extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	text = Utils.format_seconds(GameManager.main_2d.GAME_TIME_LIMIT - GameManager.main_2d.game_timer.time_left, true)
