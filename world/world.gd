extends Node3D

@onready var player: Player = $Player
@onready var world_ui: WorldUI = $WorldUI
@onready var terrain_3d: Terrain3D = $Terrain3D

@onready var background_music_player: AudioStreamPlayer = $BackgroundMusicPlayer
@onready var timer_music: Timer = $TimerMusic
@onready var audio_stream_player_noise: AudioStreamPlayer3D = $Characters/AudioStreamPlayer3DNoise

@onready var audio_stream_player_hurray: AudioStreamPlayer3D = $Characters/AudioStreamPlayer3DHurray
@onready var audio_stream_player_riot: AudioStreamPlayer3D = $Characters/AudioStreamPlayer3DRiot

@onready var men: Node3D = $Men
var last_man_killed: Man
@onready var timer_man_respawn: Timer = $TimerManRespawn
const MAN_NEW_WITH_GLB = preload("res://world/man_new_with_glb.tscn")
var transforms_for_new_man: Array[Transform3D]
@onready var wood_blocks: Node3D = $WoodBlocks

var tween_noise: Tween ## Tween to tween the volume of crowd noise

var used_at_start_menu: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var parent: Node3D = get_parent_node_3d()
	if parent and parent is StartMenu:
		used_at_start_menu = true
		player.queue_free()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return

	background_music_player.play()
	audio_stream_player_noise.play()
	terrain_3d.set_camera(player.camera)

	var men = $Men.get_children()
	for man in men:
		transforms_for_new_man.append(man.global_transform)

	var man_to_stay = men.pick_random()
	for man in men:
		if man != man_to_stay:
			man.queue_free()


func _process(_delta: float) -> void:
	if used_at_start_menu:
		process_mode = Node.PROCESS_MODE_DISABLED
		world_ui.process_mode = Node.PROCESS_MODE_DISABLED


func _on_timer_music_timeout() -> void:
	background_music_player.play()


func _on_background_music_player_finished() -> void:
	timer_music.start()


func _on_audio_stream_player_3d_noise_finished() -> void:
	audio_stream_player_noise.play()


func _on_player_hovering() -> void:
	if tween_noise and tween_noise.is_running():
		tween_noise.kill()

	tween_noise = create_tween()
	tween_noise.tween_property(audio_stream_player_noise, "volume_db", -40, 5.0)


func _on_player_attacked() -> void:
	if tween_noise and tween_noise.is_running():
		tween_noise.kill()

	tween_noise = create_tween()
	tween_noise.tween_property(audio_stream_player_noise, "volume_db", 0, 3.5)


func _on_player_hit_head(man_hit: Man, parts_hit: Array[String]) -> void:
	print("player hit head", man_hit)
	if audio_stream_player_riot.playing:
		audio_stream_player_riot.stop()

	audio_stream_player_hurray.play()
	last_man_killed = man_hit
	timer_man_respawn.start()

	world_ui.show_good_job()

	## Uniques
	var dict := {}
	for part in parts_hit:
		dict[part] = 1
	var uniques: Array = dict.keys()
	print(uniques)
	## TODO: maybe spawn rigid body with no parts


func _on_player_hit_other() -> void:
	if audio_stream_player_hurray.playing:
		audio_stream_player_hurray.stop()

	audio_stream_player_riot.play()


func _on_timer_man_respawn_timeout() -> void:
	print("Timer respawn")
	print("Removed last man killed")
	#var old_transform := last_man_killed.global_transform
	last_man_killed.queue_free()
	await get_tree().create_timer(2.0).timeout
	var new_man: Man = MAN_NEW_WITH_GLB.instantiate()
	get_tree().root.add_child(new_man)
	#new_man.global_transform = old_transform

	var children: Array = wood_blocks.get_children()
	var wood_block = children.pick_random()
	var index = children.find(wood_block)
	print(index)
	new_man.global_transform = transforms_for_new_man[index]
