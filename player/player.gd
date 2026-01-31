extends CharacterBody3D
class_name Player

const BLOOD_PARTICLE: PackedScene = preload("res://particles/blood_particle.tscn")

@onready var hud: SubViewportContainer = $HUD
@onready var camera_holder: Node3D = $CameraHolder
@onready var weapon_holder: WeaponHolder = $WeaponHolder

@export_group("Movement stats")
@export var speed: float = 6.5
@export var sprint_speed: float = 9.5
@export var acceleration: float = 3.0
@export var jump_velocity: float = 5.0
@export_group("Mouse sensitivity")
@export var sensitivity: float = 4.0
# Variables related to head bobbing (mask bobbing)
@export_group("headbob")
@export var headbob_frequency := 2.0
@export var headbob_amplitude := 0.05
var headbob_time := 0.0

const SENSITIVTY_DIVIDER: int = 100
var gravity_multiplier: float = 1.2

## Attacking state
var attack_state: AttackState = AttackState.NONE
var attack_tween: Tween

var starting_attack_rot_y: float
var attacking_rot_y_max: float = 10.0 # 10.0 degrees
var attack_y_offset: float # Current
@onready var timer_attack: Timer = $TimerAttack


enum AttackState {
	NONE,
	STARTING,
	HOVERING,
	ATTACKING
}

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if attack_state != AttackState.NONE:
			# TODO: remove return if we want to control with mouse during hovering
			return

			attack_y_offset -= deg_to_rad(
				event.screen_relative.x * sensitivity / SENSITIVTY_DIVIDER
			)

			attack_y_offset = clampf(
				attack_y_offset,
				-attacking_rot_y_max / 2,
				attacking_rot_y_max / 2
			)

			rotation.y = starting_attack_rot_y + attack_y_offset
			return

		# Rotate the player character by y-axis (left and right)
		rotate_y(deg_to_rad(-event.screen_relative.x * sensitivity / SENSITIVTY_DIVIDER))
		# Rotates the camera holder around the x-axis (up and down)
		camera_holder.rotate_x(deg_to_rad(-event.screen_relative.y * sensitivity / SENSITIVTY_DIVIDER))
		# Clamp the rotation of the camera on the x-axis to prevent turning "over" the axis
		camera_holder.rotation.x = clampf(camera_holder.rotation.x, deg_to_rad(-87), deg_to_rad(87))

		#weapon_holder.rotation.x = camera_holder.rotation.x
		## Move the weapon holder and rotate accordingly
		var look_down_weapon_holder_max_angle: float = 40
		weapon_holder.rotation.x = \
			clampf(camera_holder.rotation.x, deg_to_rad(-look_down_weapon_holder_max_angle), deg_to_rad(25))
		var z_offset: float = 0.35
		# Move the weapon holder closer if looking down
		if weapon_holder.rotation.x < 0:
			var rad: float = -rad_to_deg(weapon_holder.rotation.x)
			#print(rad)
			weapon_holder.position.z = clampf(rad / look_down_weapon_holder_max_angle * z_offset, 0.0, z_offset)
		else:
			weapon_holder.position.z = 0.0

		#print(weapon_holder.position.z)


func check_debug_controls() -> void:
	# P
	if Input.is_action_just_pressed("particle"):
		var particle := BLOOD_PARTICLE.instantiate()
		get_tree().root.add_child(particle)
		print_debug("Blood particle instantiated")
		particle.global_position = global_position - global_basis.z * 1.0
	# M
	if Input.is_action_just_pressed("mask"):
		hud.visible = not hud.visible


func attacking() -> void:
	## Starting attack
	match attack_state:
		AttackState.STARTING:
			## Wait till the camera is looking forward TODO
			## Raise camera and axe
			## Finer control of axe!!!
			if attack_tween and attack_tween.is_running():
				return

			print("Tween attacking start")
			attack_tween = create_tween().set_parallel(true)
			attack_tween.tween_property(camera_holder, "rotation:x", deg_to_rad(40), 1.0)
			attack_tween.tween_property(weapon_holder, "rotation:x", deg_to_rad(25), 1.0)
			attack_tween.tween_property(weapon_holder, "position:x", 0.1, 1.5)
			attack_tween.tween_property(weapon_holder, "rotation:y", deg_to_rad(-25), 1.5)
			attack_tween.tween_property(weapon_holder, "rotation:z", deg_to_rad(-25), 1.5)
			await attack_tween.finished
			print("Tween attacking finish")
			attack_state = AttackState.HOVERING

		AttackState.HOVERING:
			## Lock in hovering position when pressed click
			## TODO: keep mouse pressed and lock when release
			if Input.is_action_just_pressed("attack"):
				attack_state = AttackState.ATTACKING
				attack_tween.kill()
				return

			if attack_tween and attack_tween.is_running():
				return

			print("Tween hovering start")
			## Loop swing from left to right and right to left
			attack_tween = create_tween().set_ease(Tween.EASE_IN_OUT) \
				.set_trans(Tween.TRANS_CUBIC).set_loops()
			attack_tween.tween_property(weapon_holder, "position:x", 0.3, 0.5).from_current()
			attack_tween.tween_property(weapon_holder, "position:x", -0.1, 1.0)
			attack_tween.tween_property(weapon_holder, "position:x", 0.1, 0.5)
		AttackState.ATTACKING:
			if attack_tween and attack_tween.is_running() or timer_attack.time_left > 0.0:
				return

			attack_tween = create_tween().set_parallel(true)
			## Final load
			attack_tween.tween_property(camera_holder, "rotation:x", deg_to_rad(75), 0.3).from_current()
			attack_tween.tween_property(weapon_holder, "rotation:x", deg_to_rad(65), 0.4).from_current()

			## Swing
			attack_tween.chain().tween_property(camera_holder, "rotation:x", deg_to_rad(-30), 0.15).set_delay(0.05)
			attack_tween.tween_property(weapon_holder, "rotation:x", deg_to_rad(-80), 0.2)
			attack_tween.tween_property(weapon_holder, "rotation:z", deg_to_rad(-10), 0.2)
			await attack_tween.finished
			print("Tween attack finish")
			timer_attack.start()
			await timer_attack.timeout

			## Reset, tween these?
			attack_tween = create_tween().set_parallel(true)
			attack_tween.tween_property(camera_holder, "rotation:x", 0.0, 0.25)
			attack_tween.tween_property(weapon_holder, "rotation:x", 0.0, 0.25)
			attack_tween.tween_property(weapon_holder, "position:x", 0.0, 0.25)
			attack_tween.tween_property(weapon_holder, "rotation:y", 0.0, 0.25)
			attack_tween.tween_property(weapon_holder, "rotation:z", 0.0, 0.25)
			await attack_tween.finished
			attack_state = AttackState.NONE
			#camera_holder.rotation.x = 0.0
			#weapon_holder.rotation.x = 0.0
			#weapon_holder.position.x = 0.0
			#weapon_holder.rotation.y = 0.0
			#weapon_holder.rotation.z = 0.0


func _physics_process(delta: float) -> void:
	$LabelState.text = AttackState.keys()[attack_state]
	#print(weapon_holder.position.x)
	check_debug_controls()

	if attack_state == AttackState.NONE:
		if Input.is_action_just_pressed("attack"):
			starting_attack_rot_y = rotation.y
			#print("Starting attack rot y", starting_attack_rot_y)
			attack_state = AttackState.STARTING

	if attack_state != AttackState.NONE:
		attacking()
		return

	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_velocity

	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var sprinting: bool = Input.is_action_pressed("sprint")
	var actual_speed: float = sprint_speed if sprinting else speed

	if direction:
		velocity.x = direction.x * actual_speed
		velocity.z = direction.z * actual_speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	headbob_time += delta * velocity.length() * float(is_on_floor())
	$CameraHolder/Camera3D.transform.origin = headbob(headbob_time)


func headbob(headbob_time: float) -> Vector3:
	var headbob_position = Vector3.ZERO
	headbob_position.y = sin(headbob_time * headbob_frequency) * headbob_amplitude
	headbob_position.x = sin(headbob_time * headbob_frequency / 2) * headbob_amplitude
	return headbob_position
