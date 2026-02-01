extends Node3D

@onready var physical_bone_simulator: PhysicalBoneSimulator3D = $skeletor/Skeleton3D/PhysicalBoneSimulator3D

func _ready() -> void:
	#physical_bone_simulator.physical_bones_start_simulation()
	for child in physical_bone_simulator.get_children(true):
		if child is PhysicalBone3D:
			var _name: String = child.name
			#if not _name.contains("spine"):
			child.collision_layer = 2
