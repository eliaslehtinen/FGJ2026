extends Node3D
class_name StartMenu

const WORLD: PackedScene = preload("uid://dc844wcasmwtp")

@export var skip_start_menu: bool = false

@onready var credits_screen: Control = $CreditsScreen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	credits_screen.hide()
	if skip_start_menu:
		print_rich("[color=yellow]Skipping start menu[/color]")
		start_game()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit") and credits_screen.visible:
		credits_screen.hide()


func _on_button_start_pressed() -> void:
	start_game()


func _on_button_credits_pressed() -> void:
	credits_screen.show()


func _on_button_quit_pressed() -> void:
	get_tree().quit()


func start_game() -> void:
	# Throws error can't remove child 
	# because parent node is busy if no call_deferred
	get_tree().call_deferred("change_scene_to_packed", WORLD)


func _physics_process(delta: float) -> void:
	$Camera3D.rotate_y(delta * -0.5)
