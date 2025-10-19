extends Area2D
class_name TriggerArea2D

signal triggered

@export var active: bool = false:
	set(value):
		active = value
		set_active_collision_shape(!value)

@export var trigger_name: String

enum TriggerMode {
	NORMAL,
	CHAR_GROUNDED,
}

@export var trigger_mode := TriggerMode.NORMAL

var _tracked_bodies: Array[EntityCharacter2D] = []

func _ready() -> void:
	connect_signal()

func _physics_process(delta: float) -> void:
	match trigger_mode:
		TriggerMode.NORMAL:
			return
		TriggerMode.CHAR_GROUNDED:
			for body in _tracked_bodies.duplicate():
				if body.is_on_floor():
					trigger_area()
					_tracked_bodies.erase(body)
				else:
					print(body.name, " was not on the floor")

func connect_signal() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	pass


func set_active_collision_shape(_value: bool) -> void:
	for _child in get_children():
		if _child is CollisionShape2D:
			_child.disabled = _value


func trigger_area() -> void:
	EventBus.area_triggered.emit(trigger_name)
	triggered.emit()
	pass


func _on_body_entered(body: Node2D) -> void:
	if trigger_mode == TriggerMode.NORMAL:
		trigger_area()
	elif body is EntityCharacter2D:
		_tracked_bodies.push_back(body)
	pass

func _on_body_exited(body: Node2D) -> void:
	_tracked_bodies.erase(body)
