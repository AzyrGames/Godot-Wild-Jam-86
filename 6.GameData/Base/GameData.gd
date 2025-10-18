extends Node

enum CharacterType {
	PLATFORMER,
	GHOST
}

var entity_character_node: Dictionary[CharacterType, EntityCharacter2D]

var mask_tracker: EntityCharacterGhost2D

enum MapList {
	MAP_1,
	MAP_2,
	MAP_3,
	MAP_4,
	MAP_5,
}


var map_path: Dictionary[MapList, String] = {
	MapList.MAP_1: "uid://dpggt20oh3t7o",
	MapList.MAP_2: "uid://heaygjhx42wq",
	MapList.MAP_3: "uid://bp4lu5c42iak",
	MapList.MAP_4: "",
	MapList.MAP_5: "",
}

var map_default_checkpoint: Dictionary[MapList, String] = {
	MapList.MAP_1: "m1l1c1",
	MapList.MAP_2: "m2l1c1",
	MapList.MAP_3: "",
	MapList.MAP_4: "",
	MapList.MAP_5: "",
}
