extends TriggerArea2D
class_name MapTransition2D

@export var to_map: GameData.MapList

func _ready() -> void:
	super()
	EventBus.preload_map.emit(to_map)
	await get_tree().process_frame
	await get_tree().process_frame
	triggered.connect(func():
		EventBus.switch_map.emit(to_map)
	)
