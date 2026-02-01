extends Control
class_name WorldUI

@onready var panel_container: PanelContainer = $PanelContainer
@onready var panel_container_controls: PanelContainer = $PanelContainerControls
@onready var label_good_job: Label = $LabelGoodJob
@onready var player: Player = $"../Player"

var label_good_job_start_y: float

func _ready() -> void:
	panel_container.hide()
	panel_container_controls.hide()
	label_good_job.modulate.a = 0.0
	label_good_job_start_y = label_good_job.position.y


func show_good_job() -> void:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(label_good_job, "position:y", -50, 2.5).from_current()
	tween.tween_property(label_good_job, "modulate:a", 1.0, 2.5)
	tween.chain().tween_property(label_good_job, "modulate:a", 0.0, 1.0)
	await tween.finished
	label_good_job.position.y = label_good_job_start_y


func _on_button_quit_pressed() -> void:
	get_tree().quit()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("reload"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("quit"):
		var paused: bool = get_tree().paused
		if paused:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			#player.hud.visible = true
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			#player.hud.visible = false

		panel_container.visible = not paused
		panel_container_controls.visible = not paused
		get_tree().paused = not paused
