extends Node2D
# Player node
@export_node_path("CharacterBody3D") var player

# Adds parallax to hood movement

var head: Node3D
var prev_rotation: Vector2
var player_node
# How much the hood moves in relation to the camera
var offset_multiplier = 1600.0

func _ready() -> void:
	player_node = get_node(player)
	head = player_node.get_node("CameraHolder")
	prev_rotation = Vector2(head.rotation.y, head.rotation.x)

func _physics_process(delta: float) -> void:
	var current_rotation = Vector2(player_node.rotation.y, head.rotation.x)
	var dist = current_rotation - prev_rotation
	$Camera2D.offset -= dist * delta * offset_multiplier
	prev_rotation = current_rotation
	
	$Camera2D.offset = lerp($Camera2D.offset, Vector2.ZERO, 1.0 - pow(0.03, delta))
