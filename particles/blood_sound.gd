extends AudioStreamPlayer3D

func _ready() -> void:
	play()
	await finished
	play(0.09)
	await finished
	queue_free()
