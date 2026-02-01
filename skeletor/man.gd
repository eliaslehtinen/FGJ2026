extends Node3D
class_name Man

#@onready var first_bone: PhysicalBone3D = $"metarig/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone spine"
@onready var physical_bone_simulator: PhysicalBoneSimulator3D = $metarig/Skeleton3D/PhysicalBoneSimulator3D
@onready var head: MeshInstance3D = $metarig/Skeleton3D/Head_LP

func _ready() -> void:
	#physical_bone_simulator.physical_bones_start_simulation()
	for child in physical_bone_simulator.get_children(true):
		if child is PhysicalBone3D:
			var _name: String = child.name
			if not _name.contains("spine"):
				child.collision_layer = 2


func hide_mesh() -> void:
	pass
