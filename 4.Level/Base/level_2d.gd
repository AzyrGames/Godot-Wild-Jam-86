extends Node2D
class_name Level2D

const MASKABLE_ROCK: int = 4

@export
var unmasked_world: TileMapLayer
@export
var masked_tiles: TileMapLayer

func _ready() -> void:
	EventBus.mask_created.connect(_on_mask_created)
	EventBus.mask_destroyed.connect(_on_mask_destroyed)
	if masked_tiles:
		masked_tiles.clear()

func _on_mask_created(mask: Rect2i) -> void:
	if not masked_tiles or not unmasked_world:
		return
	for tx in range(mask.position.x, mask.position.x + mask.size.x):
		for ty in range(mask.position.y, mask.position.y + mask.size.y):
			var tpos := Vector2i(tx, ty)
			var td := unmasked_world.get_cell_tile_data(tpos)
			if BetterTerrain.get_tile_terrain_type(td) == MASKABLE_ROCK:
				switch_cell(unmasked_world, masked_tiles, tpos)

func _on_mask_destroyed() -> void:
	if not masked_tiles or not unmasked_world:
		return
	for tpos in masked_tiles.get_used_cells():
		switch_cell(masked_tiles, unmasked_world, tpos)

func switch_cell(from: TileMapLayer, to: TileMapLayer, tpos: Vector2i) -> void:
	to.set_cell(
		tpos,
		from.get_cell_source_id(tpos),
		from.get_cell_atlas_coords(tpos),
		from.get_cell_alternative_tile(tpos)
	)
	from.set_cell(tpos)
