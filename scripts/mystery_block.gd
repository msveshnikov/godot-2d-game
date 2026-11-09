@tool
extends StaticBody2D
## ? block pops a coin. ! block holds a surprise: 0 fruit, 1 a very confused slime, 2 a coin shower.

signal announce(text: String, at: Vector2)
signal coin_popped
signal spawn_requested(node: Node2D)

const ATLAS := preload("res://assets/sprites/world_tileset.png")
const COIN_TEX := preload("res://assets/sprites/coin.png")
const SLIME_SCENE := preload("res://scenes/objects/slime.tscn")
const Fruit := preload("res://scripts/fruit.gd")
# per style: [question, exclamation, used]
const STYLE_TILES := [
	[Vector2i(0, 2), Vector2i(1, 2), Vector2i(1, 1)],
	[Vector2i(3, 2), Vector2i(2, 3), Vector2i(3, 1)],
	[Vector2i(4, 2), Vector2i(5, 2), Vector2i(5, 1)],
	[Vector2i(7, 2), Vector2i(8, 2), Vector2i(8, 1)],
]
const COIN_JOKES := ["DING!", "+1 SHINY", "MONEY!", "CHA-CHING", "OOH COIN"]

@export var style := 0
@export var surprise := false
@export var contents := 0

var used := false
var sprite: Sprite2D

func _ready() -> void:
	add_to_group("level_events")
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 16)
	shape.shape = rect
	add_child(shape)
	sprite = Sprite2D.new()
	add_child(sprite)
	_show_tile(STYLE_TILES[style][1 if surprise else 0])

func coin_value() -> int:
	if surprise:
		return 3 if contents == 2 else 0
	return 1

func _show_tile(coords: Vector2i) -> void:
	var tex := AtlasTexture.new()
	tex.atlas = ATLAS
	tex.region = Rect2(coords * 16, Vector2(16, 16))
	sprite.texture = tex

func player_touched(_player: CharacterBody2D, normal: Vector2) -> void:
	if used or normal.y < 0.5:
		return
	used = true
	_show_tile(STYLE_TILES[style][2])
	var tween := create_tween()
	tween.tween_property(sprite, "position:y", -5.0, 0.07)
	tween.tween_property(sprite, "position:y", 0.0, 0.1)
	if not surprise:
		_pop_coin(0.0)
		coin_popped.emit()
		announce.emit(COIN_JOKES[randi() % COIN_JOKES.size()], global_position + Vector2(0, -26))
		return
	match contents:
		0:
			var fruit := Fruit.new()
			fruit.frame_index = randi() % 16
			fruit.position = position + Vector2(0, -18)
			spawn_requested.emit(fruit)
			announce.emit("A SNACK!", global_position + Vector2(0, -30))
		1:
			var slime := SLIME_SCENE.instantiate()
			slime.position = position + Vector2(0, -12)
			slime.patrol_distance = 0.0
			slime.purple = randi() % 2 == 0
			spawn_requested.emit(slime)
			announce.emit("SURPRISE SLIME!", global_position + Vector2(0, -34))
		2:
			for i in 3:
				_pop_coin(float(i - 1) * 9.0)
				coin_popped.emit()
			announce.emit("COIN FOUNTAIN!", global_position + Vector2(0, -34))

func _pop_coin(spread_x: float) -> void:
	var coin := Sprite2D.new()
	var tex := AtlasTexture.new()
	tex.atlas = COIN_TEX
	tex.region = Rect2(0, 0, 16, 16)
	coin.texture = tex
	coin.z_index = 5
	add_child(coin)
	var tween := coin.create_tween()
	tween.set_parallel(true)
	tween.tween_property(coin, "position", Vector2(spread_x, -34), 0.28).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(coin, "scale", Vector2(0.2, 1.2), 0.3)
	tween.chain().tween_property(coin, "modulate:a", 0.0, 0.15)
	tween.chain().tween_callback(coin.queue_free)
