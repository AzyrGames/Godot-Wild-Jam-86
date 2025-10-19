extends Area2D
class_name TriggerArea2D

signal triggered

enum TriggerMode {
	## whenever any body enters the area
	NORMAL,
	## when an EntityCharacter2D enters the area and is on the ground
	CHAR_GROUNDED,
}

@export var active: bool = false:
	set(value):
		active = value
		set_active_collision_shape(!value)

## Only trigger once, instead of every time a body enters
@export var oneshot: bool = false

@export var trigger_name: String

## Configure when the area should be considered triggered.
##
## EntityCharacter2Ds that enter that don't meet the requirements
## will trigger the area as soon as they do.
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
			(func(): _child.disabled = _value).call_deferred()


func trigger_area() -> void:
	if not active:
		return
	EventBus.area_triggered.emit(trigger_name)
	triggered.emit()
	if oneshot:
		active = false
	pass


func _on_body_entered(body: Node2D) -> void:
	if trigger_mode == TriggerMode.NORMAL:
		trigger_area()
	elif body is EntityCharacter2D:
		_tracked_bodies.push_back(body)
	pass

func _on_body_exited(body: Node2D) -> void:
	_tracked_bodies.erase(body)
