extends TriggerArea2D
class_name TriggerCameraContraint2D

@export var constraint_camera: Camera2D


func trigger_area() -> void:
	super()
	EventBus.change_camera_constraint.emit(constraint_camera)
	pass