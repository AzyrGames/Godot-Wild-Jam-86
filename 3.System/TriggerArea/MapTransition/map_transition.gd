extends TriggerArea2D
class_name MapTransition2D

@export var to_map: GameData.MapList

func _ready() -> void:
	super()
	EventBus.preload_map.emit(to_map)

func trigger_area() -> void:
	super()
	EventBus.switch_map.emit(to_map)
	pass
