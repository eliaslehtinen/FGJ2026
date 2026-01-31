extends Node3D
class_name WeaponHolder

const BLOOD_PARTICLES: PackedScene = preload("res://particles/blood_particle.tscn")

@onready var axe: Node3D = $axe

var current_weapon: Node3D

func _ready() -> void:
	current_weapon = axe


func _on_area_3d_body_entered(body: Node3D) -> void:
	var any_hit: bool = false
	if body is PhysicalBone3D:
		if not any_hit:
			any_hit = true
			var particles := BLOOD_PARTICLES.instantiate()
			get_tree().root.add_child(particles)
			particles.global_position = body.global_position

		print(body.name)
