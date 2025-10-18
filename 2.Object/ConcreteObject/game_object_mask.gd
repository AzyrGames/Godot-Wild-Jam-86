extends TileMapLayer

const MASK_MAX_SIZE := 9

@export var mask_bounds: Rect2i:
	set(v):
		mask_bounds = v
		update_mask()

var _old_bounds: Rect2i

func _ready() -> void:
	EventBus.mask_point_set.connect(_on_mask_start)
	EventBus.mask_track_finished.connect(_on_mask_finished.unbind(1))
	EventBus.mask_destroyed.connect(_on_mask_destroyed)

func _physics_process(_delta: float) -> void:
	process_mask()

func process_mask() -> void:
	if !GameData.mask_tracker: return
	var local_tracked_pos: Vector2 = to_local(GameData.mask_tracker.global_position)
	var new_size: Vector2i = convert_to_size(local_tracked_pos)
	# print(new_size)
	# Ensure mask is at least 1 tile in size
	if new_size.x == 0:
		new_size.x = 1
	if new_size.y == 0:
		new_size.y = 1
	if new_size != mask_bounds.size:
		mask_bounds.size = new_size
		EventBus.mask_destroyed.emit()
		update_mask()
		emit_new_mask()


func _on_mask_start(pos: Vector2) -> void:
	clear()
	mask_bounds = Rect2i(local_to_map(to_local(pos)), Vector2i.ZERO)

func _on_mask_finished() -> void:
	print("mask finished")
	emit_new_mask()
	for cell in get_used_cells():
		if BetterTerrain.get_cell(self, cell) == 1:
			BetterTerrain.set_cell(self, cell, -1)
	BetterTerrain.update_terrain_area(self, get_used_rect())

func emit_new_mask() -> void:
	EventBus.mask_created.emit(Rect2i(realize_mask_position(), mask_bounds.size.clampi(-MASK_MAX_SIZE, MASK_MAX_SIZE)).abs())

func _on_mask_destroyed() -> void:
	clear()

func convert_to_size(pos: Vector2) -> Vector2i:
	return local_to_map(pos + (pos - map_to_local(mask_bounds.position)).sign() * 18.0) - mask_bounds.position

func realize_mask_position() -> Vector2i:
	var real_mask_position = mask_bounds.position
	if mask_bounds.size.x < 0:
		real_mask_position.x += 1
	if mask_bounds.size.y < 0:
		real_mask_position.y += 1
	return real_mask_position

func update_mask() -> void:
	# Empty tilemap of existing mask

	var real_mask_pos := realize_mask_position()
	var new_bounds := Rect2i(realize_mask_position(), mask_bounds.size).abs()
	GameManager.game_ghost.set_warn_oversized(new_bounds.size.x > MASK_MAX_SIZE or new_bounds.size.y > MASK_MAX_SIZE)
	if mask_bounds.size.x == 0 or mask_bounds.size.y == 0:
		return
	# Create separate arrays of tiles to create and destroy
	var add_cells: Array[Vector2i] = []
	var oversize_cells: Array[Vector2i] = []
	var del_cells: Array[Vector2i] = []
	for rect in rect_difference(new_bounds, _old_bounds):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			for y in range(rect.position.y, rect.position.y + rect.size.y):
				if new_bounds.has_point(Vector2i(x, y)):
					if absi(x - real_mask_pos.x) < MASK_MAX_SIZE and absi(y - real_mask_pos.y) < MASK_MAX_SIZE:
						add_cells.push_back(Vector2i(x, y))
					else:
						oversize_cells.push_back(Vector2i(x, y))
				else:
					del_cells.push_back(Vector2i(x, y))
	BetterTerrain.set_cells(self, add_cells, 0)
	if GameData.mask_tracker:
		BetterTerrain.set_cells(self, oversize_cells, 1)
	BetterTerrain.set_cells(self, del_cells, -1)
	# Trigger autotile update
	BetterTerrain.update_terrain_area(self, new_bounds)
	_old_bounds = new_bounds

static func rect_difference(a: Rect2i, b: Rect2i) -> Array[Rect2i]:
	if b.encloses(a):
		var c := a
		a = b
		b = c
	var result: Array[Rect2i] = []
	var inter = a.intersection(b)
	if inter.has_area():
		result.append(a)
		return result

	# Top strip
	if inter.position.y > a.position.y:
		result.append(Rect2i(
			a.position,
			Vector2i(a.size.x, inter.position.y - a.position.y)
		))

	# Bottom strip
	var bottom = inter.position.y + inter.size.y
	if bottom < a.position.y + a.size.y:
		result.append(Rect2i(
			Vector2i(a.position.x, bottom),
			Vector2i(a.size.x, (a.position.y + a.size.y) - bottom)
		))

	# Left strip
	if inter.position.x > a.position.x:
		result.append(Rect2i(
			Vector2i(a.position.x, inter.position.y),
			Vector2i(inter.position.x - a.position.x, inter.size.y)
		))

	# Right strip
	var right = inter.position.x + inter.size.x
	if right < a.position.x + a.size.x:
		result.append(Rect2i(
			Vector2i(right, inter.position.y),
			Vector2i((a.position.x + a.size.x) - right, inter.size.y)
		))

	return result
