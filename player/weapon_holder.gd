extends Node3D
class_name WeaponHolder

const BLOOD_PARTICLES: PackedScene = preload("res://particles/blood_particle.tscn")
const BLOOD_SOUND: PackedScene = preload("res://particles/blood_sound.tscn")

@onready var axe: Node3D = $axe

var current_weapon: Node3D

const HEAD = preload("res://skeletor/limbs/head.tscn")
const ARM_L = preload("res://skeletor/limbs/arm_l.tscn")
const ARM_R = preload("res://skeletor/limbs/arm_r.tscn")
const LEG_L = preload("res://skeletor/limbs/leg_l.tscn")
const LEG_R = preload("res://skeletor/limbs/leg_r.tscn")

var parts_hit: Array[String]

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
		print("Name", _name)
		if _name.contains("head"):
			man.head.hide()
			body.get_child(0).set_deferred("disabled", true)
			owner.hit_head.emit(man, parts_hit)
			print("head")
			var head := HEAD.instantiate()
			get_tree().root.add_child(head)
			head.global_position = body.global_position
			return

		if _name.contains("shoulder_L") or _name.contains("arm_L"):
			parts_hit.append("arm_L")
			man.arm_l.hide()
			body.get_child(0).set_deferred("disabled", true)
			var arm_l := ARM_L.instantiate()
			get_tree().root.add_child(arm_l)
			arm_l.global_position = body.global_position
			print("left arm")
		if _name.contains("shoulder_R") or _name.contains("arm_R"):
			parts_hit.append("arm_R")
			man.arm_r.hide()
			body.get_child(0).set_deferred("disabled", true)
			var arm_r := ARM_R.instantiate()
			get_tree().root.add_child(arm_r)
			arm_r.global_position = body.global_position
			print("left arm")
		if _name.contains("thigh_L"):
			parts_hit.append("thigh_L")
			man.leg_l.hide()
			body.get_child(0).set_deferred("disabled", true)
			var leg_l := LEG_L.instantiate()
			get_tree().root.add_child(leg_l)
			leg_l.global_position = body.global_position
			print("left leg")
		if _name.contains("thigh_R"):
			parts_hit.append("thigh_R")
			man.leg_r.hide()
			body.get_child(0).set_deferred("disabled", true)
			var leg_r := LEG_R.instantiate()
			get_tree().root.add_child(leg_r)
			leg_r.global_position = body.global_position
			print("right leg")

		if any_hit:
			owner.hit_other.emit()
