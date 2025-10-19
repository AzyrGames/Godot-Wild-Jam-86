extends Polygon2D


func _ready() -> void:
	EventBus.character_switched.connect(_on_character_switched)
	visible = false

func _on_character_switched(new_char: GameData.CharacterType) -> void:
	visible = new_char == GameData.CharacterType.GHOST
