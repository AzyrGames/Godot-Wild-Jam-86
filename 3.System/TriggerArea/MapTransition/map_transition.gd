extends TriggerArea2D
class_name MapTransition2D

@export var to_map: GameData.MapList


func trigger_area() -> void:
	EventBus.switch_map.emit(to_map)
	pass