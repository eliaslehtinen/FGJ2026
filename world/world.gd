extends Node3D

@onready var player: Player = $Player
@onready var world_ui: Control = $WorldUI
@onready var terrain_3d: Terrain3D = $Terrain3D

var used_at_start_menu: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var parent: Node3D = get_parent_node_3d()
	if parent and parent is StartMenu:
		used_at_start_menu = true
		player.queue_free()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return

	terrain_3d.set_camera(player.camera)


func _process(_delta: float) -> void:
	if used_at_start_menu:
		process_mode = Node.PROCESS_MODE_DISABLED
		world_ui.process_mode = Node.PROCESS_MODE_DISABLED
