extends Node

enum CharacterType {
	PLATFORMER,
	GHOST
}

var entity_character_node: Dictionary[CharacterType, EntityCharacter2D]

var mask_tracker: Node2D

enum MapList {
	MAP_1,
	MAP_2,
	MAP_3,
	MAP_4,
	MAP_5,
}


var map_path: Dictionary[MapList, String] = {
	MapList.MAP_1: "",
	MapList.MAP_2: "",
	MapList.MAP_3: "",
	MapList.MAP_4: "",
	MapList.MAP_5: "",
}