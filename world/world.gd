extends Node3D

@onready var player: Player = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var parent: Node3D = get_parent_node_3d()
	if parent and parent is StartMenu:
		player.queue_free()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
