extends Control

@onready var panel_container: PanelContainer = $PanelContainer
@onready var player: Player = $"../Player"

func _ready() -> void:
	panel_container.hide()


func _on_button_quit_pressed() -> void:
	get_tree().quit()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		var paused: bool = get_tree().paused
		if paused:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			player.hud.visible = true
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			player.hud.visible = false

		panel_container.visible = not paused
		get_tree().paused = not paused
