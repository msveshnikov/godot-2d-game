extends Area2D

const GREEN_TEXTURE := preload("res://assets/sprites/slime_green.png")
const PURPLE_TEXTURE := preload("res://assets/sprites/slime_purple.png")

signal stomped
signal hit_player

@export var patrol_distance := 48.0
@export var move_speed := 38.0
@export var purple := false

var start_x := 0.0
var direction := 1.0
var time := 0.0
var atlas: AtlasTexture
var dead := false

func _ready() -> void:
	start_x = position.x
	atlas = AtlasTexture.new()
	atlas.atlas = PURPLE_TEXTURE if purple else GREEN_TEXTURE
	atlas.region = Rect2(0, 0, 24, 24)
	$Sprite.texture = atlas
	time = randf() * 2.0
	direction = 1.0 if randi() % 2 == 0 else -1.0
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if dead:
		return
	time += delta
	atlas.region.position.x = float(int(time * 8.0) % 4) * 24.0
	if patrol_distance <= 0.0:
		return
	position.x += direction * move_speed * delta
	if position.x < start_x - patrol_distance:
		position.x = start_x - patrol_distance
		direction = 1.0
	elif position.x > start_x + patrol_distance:
		position.x = start_x + patrol_distance
		direction = -1.0
	$Sprite.flip_h = direction < 0.0

func _on_body_entered(body: Node2D) -> void:
	if dead or not body.is_in_group("player"):
		return
	var player := body as CharacterBody2D
	if player.velocity.y > 45.0 and player.global_position.y < global_position.y + 24.0:
		dead = true
		set_deferred("monitoring", false)
		stomped.emit()
		player.velocity.y = -260.0
		# squish into a pancake, then vanish
		atlas.region.position = Vector2(48, 48)
		var tween := create_tween().set_parallel(true)
		tween.tween_property($Sprite, "scale", Vector2(1.8, 0.25), 0.12)
		tween.tween_property($Sprite, "position:y", -2.0, 0.12)
		tween.chain().tween_property($Sprite, "modulate:a", 0.0, 0.3)
		tween.chain().tween_callback(queue_free)
	else:
		hit_player.emit()
