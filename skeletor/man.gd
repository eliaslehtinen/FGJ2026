extends Node3D
class_name Man

#@onready var first_bone: PhysicalBone3D = $"metarig/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone spine"
@onready var physical_bone_simulator: PhysicalBoneSimulator3D = $metarig/Skeleton3D/PhysicalBoneSimulator3D

@onready var head: MeshInstance3D = $metarig/Skeleton3D/body_head
@onready var arm_l: MeshInstance3D = $metarig/Skeleton3D/body_arm_L
@onready var arm_r: MeshInstance3D = $metarig/Skeleton3D/body_arm_R
@onready var leg_l: MeshInstance3D = $metarig/Skeleton3D/body_leg_L
@onready var leg_r: MeshInstance3D = $metarig/Skeleton3D/body_leg_R

func _ready() -> void:
	#physical_bone_simulator.physical_bones_start_simulation()
	for child in physical_bone_simulator.get_children(true):
		if child is PhysicalBone3D:
			#var _name: String = child.name
			#if not _name.contains("spine"):
			child.collision_layer = 2
