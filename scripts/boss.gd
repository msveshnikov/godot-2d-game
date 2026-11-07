extends Area2D

signal stomped
signal hit_player

var home_position := Vector2.ZERO
var time := 0.0
var hit_cooldown := 0.0

func _ready() -> void:
	home_position = position
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	time += delta
	hit_cooldown = maxf(0.0, hit_cooldown - delta)
	position.x = home_position.x + sin(time * 1.2) * 115.0
	position.y = home_position.y + absf(sin(time * 1.7)) * 14.0

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or hit_cooldown > 0.0:
		return
	var player := body as CharacterBody2D
	if player.velocity.y > 40.0 and player.global_position.y < global_position.y + 44.0:
		hit_cooldown = 0.75
		stomped.emit()
		player.velocity.y = -300.0
	else:
		hit_player.emit()
