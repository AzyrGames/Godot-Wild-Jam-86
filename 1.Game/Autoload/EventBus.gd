# class_name EventBus
extends Node

signal trait_added(component_name: String, node: Node)
signal trait_removed(component_name: String, node: Node)
signal component_added(component_name: String, node: Node)
signal component_removed(component_name: String, node: Node)
signal component_enabled(component_name: String)
signal component_disabled(component_name: String)



signal start_game
signal pause_game

signal exit_game
signal quit_game

signal game_started
signal game_paused(_paused: bool)
signal game_exited
signal game_frozen(time_scale: float, duration: float)
signal game_unfrozen()


signal is_full_screen(_value: bool)

signal character_switched(_charcter: GameData.CharacterType)

signal area_triggered(_trigger_name: String)
signal switch_map(_to_map: GameData.MapList)
signal game_map_changed

signal change_camera_constraint(_constraint_camera: Camera2D)

# Signals for handling creation of masks (internal logic)
## Emitted when a mask is started. Position is in global non-grid coordinates.
signal mask_point_set(_pos: Vector2)
## Emitted when a mask is completed and ready to be emitted.
## Note: This is NOT the mask completion signal - that is handled by `mask_created`.
## Position is in global non-grid coordinates.
signal mask_track_finished(_pos: Vector2)
## Emitted when a mask is cancelled and visuals/state needs to be cleaned up.
signal mask_track_abort()
# Signals for interacting with masks (external logic)
## Emitted when a mask is created. The position and size of the mask are in global grid coordinates.
signal mask_created(mask: Rect2i)
## Emitted when a mask is deleted.
signal mask_destroyed()


## Emitted when checkpoint is entered or exited
signal check_point_entered(_value: bool)
