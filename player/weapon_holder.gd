extends Node3D
class_name WeaponHolder

@onready var axe: Node3D = $axe

var current_weapon: Node3D

func _ready() -> void:
	current_weapon = axe


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is PhysicalBone3D:
		print(body.name)
