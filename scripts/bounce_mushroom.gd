@tool
extends StaticBody2D
## Land on it and get flung into the sky.

signal announce(text: String, at: Vector2)

const ATLAS := preload("res://assets/sprites/world_tileset.png")
const BOING_WORDS := ["BOING!", "BWOMP!", "SPROING!", "WHEEE!", "BOINGG!", "YEET!"]

@export_range(0, 3) var variant := 0
@export var launch_speed := 560.0

var sprite: Sprite2D

func _ready() -> void:
	add_to_group("level_events")
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 10)
	shape.shape = rect
	shape.position = Vector2(0, -3)
	add_child(shape)
	sprite = Sprite2D.new()
	var tex := AtlasTexture.new()
	tex.atlas = ATLAS
	tex.region = Rect2(112, 80 + variant * 16, 16, 16)
	sprite.texture = tex
	sprite.offset = Vector2(0, -8)
	sprite.position = Vector2(0, 8)
	add_child(sprite)

func player_touched(player: CharacterBody2D, normal: Vector2) -> void:
	if normal.y > -0.5:
		return
	player.bounce(launch_speed)
	announce.emit(BOING_WORDS[randi() % BOING_WORDS.size()], global_position + Vector2(0, -24))
	var tween := create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.5, 0.5), 0.05)
	tween.tween_property(sprite, "scale", Vector2(0.8, 1.3), 0.09)
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.12)
