extends Node3D
class_name WeaponHolder

@onready var axe: Node3D = $axe

var current_weapon: Node3D

func _ready() -> void:
	current_weapon = axe


func _process(_delta: float) -> void:
	pass
