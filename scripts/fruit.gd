@tool
extends Area2D
## Eat it: SUGAR RUSH (faster, bouncier, rainbow knight) for a few seconds.

signal announce(text: String, at: Vector2)
signal eaten

const FRUIT_TEX := preload("res://assets/sprites/fruit.png")
const RUSH_WORDS := ["SUGAR RUSH!", "VITAMINS!!", "ZOOM ZOOM!", "CRUNCHY!", "FRUIT POWER!"]

@export_range(0, 15) var frame_index := 0

var sprite: Sprite2D
var time := 0.0

func _ready() -> void:
	add_to_group("level_events")
	collision_layer = 2
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 8.0
	shape.shape = circle
	add_child(shape)
	sprite = Sprite2D.new()
	var tex := AtlasTexture.new()
	tex.atlas = FRUIT_TEX
	tex.region = Rect2((frame_index % 4) * 16, (frame_index >> 2) * 16, 16, 16)
	sprite.texture = tex
	add_child(sprite)
	time = position.x * 0.05
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	time += delta
	sprite.position.y = sin(time * 4.0) * 2.5
	sprite.rotation = sin(time * 2.3) * 0.2

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	set_deferred("monitoring", false)
	body.sugar_rush(7.0)
	eaten.emit()
	announce.emit(RUSH_WORDS[randi() % RUSH_WORDS.size()], global_position + Vector2(0, -20))
	var tween := create_tween().set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2(2.2, 2.2), 0.2)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.2)
	tween.chain().tween_callback(queue_free)
