extends Node2D
class_name Level2D

const MASKABLE_ROCK: int = 4
const MASK_OUT_ROCK: int = 5
const ONEWAY: int = 6

@export
var unmasked_world: TileMapLayer
@export
var masked_tiles: TileMapLayer
@export
var oneway_layer: TileMapLayer

func _ready() -> void:
	EventBus.mask_created.connect(_on_mask_created)
	EventBus.mask_destroyed.connect(_on_mask_destroyed)
	if not unmasked_world or not masked_tiles:
		printerr("Level ", name, " needs to have mask and unmasked tilemaplayers")
		return
	masked_tiles.clear()
	for tpos in unmasked_world.get_used_cells():
		if BetterTerrain.get_cell(unmasked_world, tpos) == MASK_OUT_ROCK:
			switch_cell(unmasked_world, masked_tiles, tpos)
		elif BetterTerrain.get_cell(unmasked_world, tpos) == ONEWAY:
			BetterTerrain.set_cell(oneway_layer, tpos, 0)
			BetterTerrain.set_cell(unmasked_world, tpos, -1)
	BetterTerrain.update_terrain_area(oneway_layer, oneway_layer.get_used_rect())


func _on_mask_created(mask: Rect2i) -> void:
	if not masked_tiles or not unmasked_world:
		return
	for tx in range(mask.position.x, mask.position.x + mask.size.x):
		for ty in range(mask.position.y, mask.position.y + mask.size.y):
			var tpos := Vector2i(tx, ty)
			if BetterTerrain.get_cell(unmasked_world, tpos) == MASKABLE_ROCK:
				switch_cell(unmasked_world, masked_tiles, tpos)
			elif BetterTerrain.get_cell(masked_tiles, tpos) == MASK_OUT_ROCK:
				switch_cell(masked_tiles, unmasked_world, tpos)

func _on_mask_destroyed() -> void:
	if not masked_tiles or not unmasked_world:
		return
	for tpos in unmasked_world.get_used_cells():
		if BetterTerrain.get_cell(unmasked_world, tpos) == MASK_OUT_ROCK:
			switch_cell(unmasked_world, masked_tiles, tpos)
	for tpos in masked_tiles.get_used_cells():
		if BetterTerrain.get_cell(masked_tiles, tpos) == MASKABLE_ROCK:
			switch_cell(masked_tiles, unmasked_world, tpos)

func switch_cell(from: TileMapLayer, to: TileMapLayer, tpos: Vector2i) -> void:
	to.set_cell(
		tpos,
		from.get_cell_source_id(tpos),
		from.get_cell_atlas_coords(tpos),
		from.get_cell_alternative_tile(tpos)
	)
	from.set_cell(tpos)
