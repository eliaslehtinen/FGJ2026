extends Node3D
class_name WeaponHolder

const BLOOD_PARTICLES: PackedScene = preload("res://particles/blood_particle.tscn")
const BLOOD_SOUND: PackedScene = preload("res://particles/blood_sound.tscn")

@onready var axe: Node3D = $axe

var current_weapon: Node3D

const HEAD = preload("res://skeletor/limbs/head.tscn")
#const ARM_L = preload("res://skeletor/limbs/arm_l.tscn")
#const ARM_R = preload("res://skeletor/limbs/arm_r.tscn")
#const LEG_L = preload("res://skeletor/limbs/leg_l.tscn")
#const LEG_R = preload("res://skeletor/limbs/leg_r.tscn")

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

			var blood_sound := BLOOD_SOUND.instantiate()
			get_tree().root.add_child(blood_sound)
			blood_sound.global_position = body.global_position

			$axe/AudioStreamPlayer3DHit.play()

		var man: Man = body.owner
		var _name: String = body.name
		print(_name)
		if _name.contains("head"):
			## Head
			man.head.hide()
			## Spawn head
			owner.hit_head.emit()
			print("head")
			var head := HEAD.instantiate()
			get_tree().root.add_child(head)
			head.global_position = body.global_position
			return

		if _name.contains("shoulder_L") or _name.contains("arm_L"):
			## Left arm
			print("left arm")
		if _name.contains("shoulder_R") or _name.contains("arm_R"):
			## Right arm
			print("right arm")
		if _name.contains("thigh_L"):
			print("left leg")
		if _name.contains("thigh_R"):
			print("right leg")

		if any_hit:
			owner.hit_other.emit()
