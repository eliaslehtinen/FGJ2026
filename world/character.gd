extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	await get_tree().create_timer(randf_range(0.1, 0.7)).timeout
	animation_player.play("waiting")
