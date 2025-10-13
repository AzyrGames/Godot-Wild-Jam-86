extends Node2D

# variables
@export var speed : float = 170.0

var cornerA : Vector2
var cornerB : Vector2
var is_ghost_mode : bool = true

# ghost states
enum States {
	NONE, 
	CORNER_A_PLACED,
	CORNER_B_PLACED,
	PLATFORM
}

var ghost_state : States = States.NONE


func _physics_process(delta: float) -> void:
	# handle movement
	var direction = Input.get_vector("ghost_left", "ghost_right", "ghost_up", "ghost_down")
	
	if direction:
		if ghost_state != States.PLATFORM and ghost_state != States.CORNER_B_PLACED:
			global_position += direction * speed * delta
	
	# handle ghost states
	match ghost_state:
		States.NONE:
			if Input.is_action_just_pressed("ghost_action"):
				cornerA = self.global_position
				ghost_state = States.CORNER_A_PLACED
				
				print("cornerA: " + str(cornerA))
				
		States.CORNER_A_PLACED:
			if Input.is_action_just_pressed("ghost_action"):
				cornerB = self.global_position
				ghost_state = States.CORNER_B_PLACED
				
				print("cornerB: " + str(cornerB))
				
		States.CORNER_B_PLACED:
			if Input.is_action_just_pressed("ghost_action"):
				var platform_sprite : Sprite2D = Sprite2D.new()
				add_child(platform_sprite)
				platform_sprite.texture = load("res://icon.svg")
				platform_sprite.position = cornerA
				platform_sprite.scale.x = cornerB.x / platform_sprite.texture.get_width()
				platform_sprite.scale.y = cornerB.y / platform_sprite.texture.get_height()
				ghost_state = States.PLATFORM
				
		States.PLATFORM:
			$GhostSprite.visible = false
		
				
				
				
	
	
	
