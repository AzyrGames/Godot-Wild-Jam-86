extends Area2D
class_name TriggerArea2D

@export var active: bool = false:
	set(value):
		active = value
		set_active_collision_shape(!value)
@export var trigger_name: String


func _ready() -> void:
	connect_signal()


func connect_signal() -> void:
	body_entered.connect(_on_body_entered)
	pass


func set_active_collision_shape(_value: bool) -> void:
	for _child in get_children():
		if _child is CollisionShape2D:
			_child.disabled = _value


func trigger_area() -> void:
	EventBus.area_triggered.emit(trigger_name)
	pass


func _on_body_entered(_body: Node2D) -> void:
	trigger_area()
	pass