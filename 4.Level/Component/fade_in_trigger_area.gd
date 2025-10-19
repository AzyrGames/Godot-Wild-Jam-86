extends TriggerArea2D

@export var duration := 1.0

@export_exp_easing var fade_ease := 1.0


func _ready() -> void:
	super()
	modulate.a = 0.0
	triggered.connect(func():
		create_tween().tween_method(func(v):
			modulate.a = ease(v, fade_ease), 0.0, 1.0, duration)
	)
