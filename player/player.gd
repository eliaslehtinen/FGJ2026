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

const SENSITIVTY_DIVIDER: int = 100
var gravity_multiplier: float = 1.2

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Rotate the player character by y-axis (left and right)
		rotate_y(deg_to_rad(-event.screen_relative.x * sensitivity / SENSITIVTY_DIVIDER))
		# Rotates the camera holder around the x-axis (up and down)
		camera_holder.rotate_x(deg_to_rad(-event.screen_relative.y * sensitivity / SENSITIVTY_DIVIDER))
		# Clamp the rotation of the camera on the x-axis to prevent turning "over" the axis
		camera_holder.rotation.x = clampf(camera_holder.rotation.x, deg_to_rad(-87), deg_to_rad(87))

		## Move the weapon holder and rotate accordingly
		#weapon_holder.rotation.x = camera_holder.rotation.x
		var look_down_weapon_holder_max_angle: float = 40
		weapon_holder.rotation.x = \
			clampf(camera_holder.rotation.x, deg_to_rad(-look_down_weapon_holder_max_angle), deg_to_rad(25))
		var z_offset: float = 0.35
		# Move the weapon holder closer if looking down
		if weapon_holder.rotation.x < 0:
			var rad: float = -rad_to_deg(weapon_holder.rotation.x)
			print(rad)
			weapon_holder.position.z = clampf(rad / look_down_weapon_holder_max_angle * z_offset, 0.0, z_offset)
		else:
			weapon_holder.position.z = 0.0

		print(weapon_holder.position.z)


func check_debug_controls() -> void:
	if Input.is_action_just_pressed("particle"):
		var particle := BLOOD_PARTICLE.instantiate()
		get_tree().root.add_child(particle)
		print_debug("Blood particle instantiated")
		particle.global_position = global_position - global_basis.z * 1.0
	if Input.is_action_just_pressed("mask"):
		hud.visible = not hud.visible


func _physics_process(delta: float) -> void:
	check_debug_controls()

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
