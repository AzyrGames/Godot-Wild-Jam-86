extends TileMapLayer

@export var mask_position: Vector2i = Vector2i(0, 0):
	set(v):
		mask_position = v
		update_mask()
@export var mask_size: Vector2i = Vector2i(0, 0):
	set(v):
		mask_size = v
		update_mask()

func _ready() -> void:
	EventBus.mask_point_set.connect(_on_mask_start)
	EventBus.mask_track_finished.connect(_on_mask_end)
	# EventBus.mask_destroyed.connect(_on_mask_destroyed)

func _physics_process(_delta: float) -> void:
	process_mask()

var local_tracked_pos: Vector2
var new_size: Vector2i

var last_mask_position: Vector2

func process_mask() -> void:
	if !GameData.mask_tracker: return
	if last_mask_position == GameData.mask_tracker.global_position: return
	last_mask_position = GameData.mask_tracker.global_position
	local_tracked_pos = to_local(GameData.mask_tracker.global_position)
	new_size = convert_to_size(local_tracked_pos)
	# expand by 1 to enclose ghost in mask
	#new_size += (Vector2i(1, 1) * new_size.sign())
	# 0 components result in 0 sign so handle those cases
	if new_size.x == 0:
		new_size.x = 1
	if new_size.y == 0:
		new_size.y = 1
	if new_size != mask_size:
		mask_size = new_size
		EventBus.mask_destroyed.emit()
		update_mask()
	_on_mask_end(GameData.mask_tracker.global_position)


func _on_mask_start(pos: Vector2) -> void:
	mask_position = local_to_map(to_local(pos))

func _on_mask_end(pos: Vector2) -> void:
	mask_size = convert_to_size(to_local(pos))
	var real_mask_position = mask_position
	if mask_size.x < 0:
		real_mask_position.x += 1
	if mask_size.y < 0:
		real_mask_position.y += 1
	EventBus.mask_created.emit(Rect2i(real_mask_position, mask_size).abs())

func _on_mask_destroyed() -> void:
	clear()

func convert_to_size(pos: Vector2) -> Vector2i:
	return local_to_map(pos + (pos - map_to_local(mask_position)).sign() * 18.0) - mask_position

func update_mask() -> void:
	# Empty tilemap of existing mask
	clear()
	if mask_size.x == 0 or mask_size.y == 0:
		return
	# Create array of tiles to update, abs size is necessary for indexing/range to behave well
	var abs_size := mask_size.abs()
	var coords: Array[Vector2i] = []
	coords.resize(abs_size.x * abs_size.y)
	for x in abs_size.x:
		for y in abs_size.y:
			coords[x * abs_size.y + y] = mask_position + Vector2i(x if mask_size.x > 0 else -x, y if mask_size.y > 0 else -y)
	BetterTerrain.set_cells(self, coords, 0)
	# Trigger autotile update
	BetterTerrain.update_terrain_area(self, Rect2i(mask_position, mask_size).abs())
