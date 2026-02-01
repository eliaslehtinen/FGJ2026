extends CharacterBody3D
class_name Player

const BLOOD_PARTICLES: PackedScene = preload("res://particles/blood_particle.tscn")

@onready var hud: SubViewportContainer = $HUD
@onready var camera_holder: Node3D = $CameraHolder
@onready var camera: Camera3D = $CameraHolder/Camera3D
@onready var ray_cast: RayCast3D = $CameraHolder/RayCast3D
@onready var weapon_holder: WeaponHolder = $WeaponHolder
@onready var drag_point: Node3D = $DragPoint


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

@onready var audio_walk_ground: AudioStreamPlayer = $AudioWalkGround
@onready var audio_walk_wood: AudioStreamPlayer = $AudioWalkWood
var is_on_wood: bool = false

const SENSITIVTY_DIVIDER: int = 100
var gravity_multiplier: float = 1.2

## Attacking state
var attack_state: AttackState = AttackState.NONE
var attack_tween: Tween

var starting_attack_rot_y: float
var attacking_rot_y_max: float = 10.0 # 10.0 degrees
var attack_y_offset: float # Current
@onready var timer_attack: Timer = $TimerAttack
@onready var weapon_area: Area3D = $WeaponHolder/axe/Area3D

enum AttackState {
	NONE,
	STARTING,
	HOVERING,
	ATTACKING
}

var dragged_man: Man

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	weapon_area.monitoring = false


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
		var particles := BLOOD_PARTICLES.instantiate()
		get_tree().root.add_child(particles)
		print_debug("Blood particle instantiated")
		particles.global_position = global_position - global_basis.z * 1.0
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
			if Input.is_action_just_pressed("right_click"):
				attack_state = AttackState.NONE
				attack_tween.kill()
				reset_weapon_transforms()

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

			weapon_area.monitoring = true
			attack_tween = create_tween().set_parallel(true)
			var wh_x: float = weapon_holder.position.x
			if wh_x > 0.2: # Right
				print("Over 0.2")
				attack_tween.tween_property(weapon_holder, "position:x", 0.7, 0.3)
			elif wh_x > 0.12: # Slightly right
				print("Over 0.12")
				attack_tween.tween_property(weapon_holder, "position:x", 0.35, 0.3)
			elif wh_x < -0.05: # Left
				print("Less -0.05")
				attack_tween.tween_property(weapon_holder, "position:x", -0.35, 0.3)
			else: # Middle
				attack_tween.tween_property(weapon_holder, "position:x", 0.15, 0.3)

			## Final load
			attack_tween.tween_property(camera_holder, "rotation:x", deg_to_rad(75), 0.3).from_current()
			attack_tween.tween_property(weapon_holder, "rotation:x", deg_to_rad(65), 0.4).from_current()

			## Swing
			attack_tween.chain().tween_property(camera_holder, "rotation:x", deg_to_rad(-30), 0.15).set_delay(0.05)
			attack_tween.tween_property(weapon_holder, "rotation:x", deg_to_rad(-80), 0.2)
			attack_tween.tween_property(weapon_holder, "rotation:z", deg_to_rad(0), 0.2)
			await attack_tween.finished
			print("Tween attack finish")
			weapon_area.monitoring = false
			timer_attack.start()
			await timer_attack.timeout

			## Reset, tween these?
			reset_weapon_transforms()
			await attack_tween.finished
			attack_state = AttackState.NONE
			#camera_holder.rotation.x = 0.0
			#weapon_holder.rotation.x = 0.0
			#weapon_holder.position.x = 0.0
			#weapon_holder.rotation.y = 0.0
			#weapon_holder.rotation.z = 0.0


func reset_weapon_transforms() -> void:
	attack_tween = create_tween().set_parallel(true)
	attack_tween.tween_property(camera_holder, "rotation:x", 0.0, 0.25)
	attack_tween.tween_property(weapon_holder, "rotation:x", 0.0, 0.25)
	attack_tween.tween_property(weapon_holder, "position:x", 0.0, 0.25)
	attack_tween.tween_property(weapon_holder, "rotation:y", 0.0, 0.25)
	attack_tween.tween_property(weapon_holder, "rotation:z", 0.0, 0.25)


func _physics_process(delta: float) -> void:
	$LabelState.text = AttackState.keys()[attack_state]
	#print(weapon_holder.position.x)
	check_debug_controls()

	if attack_state == AttackState.NONE and is_on_floor():
		if Input.is_action_just_pressed("attack"):
			starting_attack_rot_y = rotation.y
			#print("Starting attack rot y", starting_attack_rot_y)
			attack_state = AttackState.STARTING

	if attack_state != AttackState.NONE and is_on_floor():
		attacking()
		return

	#if Input.is_action_just_pressed("drag"):
	#	if ray_cast.is_colliding():
	#		if dragged_man:
	#			dragged_man = null
	#			return

	#		print("Colliding with man")
	#		var collider: Object = ray_cast.get_collider()
	#		var _owner = collider.owner
	#		if _owner is Man and not dragged_man:
	#			print("Assigned dragged man", _owner)
	#			dragged_man = _owner

	#if dragged_man:
	#	dragged_man.first_bone
	#	dragged_man.global_position = dragged_man.global_position.lerp( \
	#		drag_point.global_position, delta * 5.0)

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

	if velocity != Vector3.ZERO and is_on_floor():
		print(is_on_wood)
		if is_on_wood and not audio_walk_wood.playing:
			audio_walk_wood.play()
			print("play wood")
		elif not audio_walk_ground.playing:
			audio_walk_ground.play()
			print("play ground")

	headbob_time += delta * velocity.length() * float(is_on_floor())
	$CameraHolder/Camera3D.transform.origin = headbob(headbob_time)

	move_and_slide()


func headbob(hb_time: float) -> Vector3:
	var headbob_position = Vector3.ZERO
	headbob_position.y = sin(hb_time * headbob_frequency) * headbob_amplitude
	headbob_position.x = sin(hb_time * headbob_frequency / 2) * headbob_amplitude
	return headbob_position


func _on_area_3d_body_entered(body: Node3D) -> void:
	is_on_wood = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	is_on_wood = false
