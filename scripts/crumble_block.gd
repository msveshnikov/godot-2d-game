@tool
extends StaticBody2D
## Ice cube that wobbles, cracks and drops a moment after you stand on it. Grows back later.

signal announce(text: String, at: Vector2)

const ATLAS := preload("res://assets/sprites/world_tileset.png")
const CRACK_WORDS := ["CRACK!", "UH OH", "WOBBLE", "NOPE!", "eep"]

var sprite: Sprite2D
var shape: CollisionShape2D
var crumbling := false

func _ready() -> void:
	add_to_group("level_events")
	shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 16)
	shape.shape = rect
	add_child(shape)
	sprite = Sprite2D.new()
	var tex := AtlasTexture.new()
	tex.atlas = ATLAS
	tex.region = Rect2(96, 32, 16, 16)
	sprite.texture = tex
	add_child(sprite)

func player_touched(_player: CharacterBody2D, normal: Vector2) -> void:
	if crumbling or normal.y > -0.5:
		return
	crumbling = true
	if randi() % 3 == 0:
		announce.emit(CRACK_WORDS[randi() % CRACK_WORDS.size()], global_position + Vector2(0, -20))
	var tween := create_tween()
	for i in 6:
		tween.tween_property(sprite, "position:x", 1.5 if i % 2 == 0 else -1.5, 0.06)
	tween.tween_callback(_drop)

func _drop() -> void:
	shape.set_deferred("disabled", true)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(sprite, "position", Vector2(0, 90), 0.6).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(sprite, "rotation", 1.4, 0.6)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.6)
	tween.chain().tween_interval(2.6)
	tween.chain().tween_callback(_regrow)

func _regrow() -> void:
	sprite.position = Vector2.ZERO
	sprite.rotation = 0.0
	sprite.scale = Vector2(0.1, 0.1)
	sprite.modulate.a = 1.0
	shape.set_deferred("disabled", false)
	var tween := create_tween()
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func(): crumbling = false)
