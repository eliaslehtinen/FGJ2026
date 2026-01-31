extends Node3D

@onready var physical_bone_simulator: PhysicalBoneSimulator3D = $skeletor/Skeleton3D/PhysicalBoneSimulator3D

func _ready() -> void:
	for child in physical_bone_simulator.get_children(true):
		if child is PhysicalBone3D:
			child.collision_layer = 2
			child.hide()
