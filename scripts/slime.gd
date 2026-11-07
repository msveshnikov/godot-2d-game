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

func _ready() -> void:
	start_x = position.x
	var atlas := AtlasTexture.new()
	atlas.atlas = PURPLE_TEXTURE if purple else GREEN_TEXTURE
	atlas.region = Rect2(0, 0, 24, 24)
	$Sprite.texture = atlas
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position.x += direction * move_speed * delta
	if position.x < start_x - patrol_distance:
		position.x = start_x - patrol_distance
		direction = 1.0
	elif position.x > start_x + patrol_distance:
		position.x = start_x + patrol_distance
		direction = -1.0
	$Sprite.flip_h = direction < 0.0

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	var player := body as CharacterBody2D
	if player.velocity.y > 45.0 and player.global_position.y < global_position.y + 24.0:
		set_deferred("monitoring", false)
		stomped.emit()
		player.velocity.y = -260.0
		queue_free()
	else:
		hit_player.emit()
