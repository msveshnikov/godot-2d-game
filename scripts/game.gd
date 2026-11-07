extends Node2D

const TITLE_SCENE := preload("res://scenes/title_screen.tscn")
const LEVEL_SCENES: Array[PackedScene] = [
	preload("res://scenes/levels/biscuit_woods.tscn"),
	preload("res://scenes/levels/wobblepop_bridge.tscn"),
	preload("res://scenes/levels/gumdrop_heights.tscn"),
	preload("res://scenes/levels/cloudtop_circus.tscn"),
	preload("res://scenes/levels/mooncheese_mine.tscn"),
	preload("res://scenes/levels/big_slime_boss.tscn"),
]

@onready var scene_container: Node2D = $SceneContainer

var current_level_index := 0
var current_scene: Node
var playing := false

func _ready() -> void:
	$Music.finished.connect(_restart_music)
	$Music.play()
	_show_title()

func _show_title() -> void:
	_clear_current_scene()
	current_scene = TITLE_SCENE.instantiate()
	current_scene.connect("start_pressed", _start_game)
	scene_container.add_child(current_scene)

func _start_game() -> void:
	playing = true
	current_level_index = 0
	_load_level(current_level_index)

func _load_level(level_index: int) -> void:
	if level_index < 0 or level_index >= LEVEL_SCENES.size():
		push_error("Level index is out of range: %d" % level_index)
		return
	_clear_current_scene()
	current_level_index = level_index
	current_scene = LEVEL_SCENES[level_index].instantiate()
	current_scene.connect("completed", _on_level_completed)
	current_scene.connect("failed", _on_level_failed)
	current_scene.connect("boss_beaten", _on_boss_beaten)
	scene_container.add_child(current_scene)

func _on_level_completed() -> void:
	_load_level(current_level_index + 1)

func _on_level_failed() -> void:
	_load_level(current_level_index)

func _on_boss_beaten() -> void:
	playing = false
	_clear_current_scene()
	current_scene = TITLE_SCENE.instantiate()
	current_scene.call("set_victory")
	current_scene.connect("start_pressed", _start_game)
	scene_container.add_child(current_scene)

func _clear_current_scene() -> void:
	if is_instance_valid(current_scene):
		scene_container.remove_child(current_scene)
		current_scene.queue_free()
		current_scene = null

func _restart_music() -> void:
	$Music.play()

func _unhandled_input(event: InputEvent) -> void:
	if playing and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		_load_level(current_level_index)
