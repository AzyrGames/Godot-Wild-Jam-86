extends PanelContainer

@export var non_ghost_text: Control
@export var ghost_text: Control
@export var masking_text: Control
@export var mask_done_text: Control

var switch_tween: Tween

var _is_ghost := false
var _is_masking := false
var _is_mask_complete := false

func _ready() -> void:
	if ghost_text:
		ghost_text.modulate = Color(1.0, 1.0, 1.0, 0.0)
		ghost_text.visible = true
	if masking_text:
		masking_text.modulate = Color(1.0, 1.0, 1.0, 0.0)
		masking_text.visible = true

	non_ghost_text.modulate = Color(1.0, 1.0, 1.0, 1.0)
	non_ghost_text.visible = true

func _process(delta: float) -> void:
	var is_ghost := GameManager.game_ghost.active
	var is_masking := GameData.mask_tracker == GameManager.game_ghost
	var is_mask_complete := GameManager.current_mask.has_area()
	if _is_ghost == is_ghost and _is_masking == is_masking and _is_mask_complete == is_mask_complete:
		return
	if switch_tween:
		switch_tween.kill()
	switch_tween = create_tween().set_parallel()
	if is_mask_complete and mask_done_text:
		tween(non_ghost_text, 0.0)
		tween(ghost_text, 0.0)
		tween(masking_text, 0.0)
		tween(mask_done_text, 1.0)
	elif is_masking and masking_text:
		tween(non_ghost_text, 0.0)
		tween(ghost_text, 0.0)
		tween(masking_text, 1.0)
		tween(mask_done_text, 0.0)
	elif is_ghost and ghost_text:
		tween(non_ghost_text, 0.0)
		tween(ghost_text, 1.0)
		tween(masking_text, 0.0)
		tween(mask_done_text, 0.0)
	else:
		tween(non_ghost_text, 1.0)
		tween(ghost_text, 0.0)
		tween(masking_text, 0.0)
		tween(mask_done_text, 0.0)
	_is_ghost = is_ghost
	_is_masking = is_masking
	_is_mask_complete = is_mask_complete

func tween(obj: Control, alpha: float) -> void:
	if not obj:
		return
	switch_tween.tween_property(obj, ^"modulate", Color(1.0, 1.0, 1.0, alpha), 0.25)
