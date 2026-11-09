extends Area2D

signal collected

var time := 0.0
var atlas: AtlasTexture

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	atlas = ($Sprite.texture as AtlasTexture).duplicate()
	$Sprite.texture = atlas
	time = position.x * 0.013

func _process(delta: float) -> void:
	time += delta
	atlas.region.position.x = float(int(time * 12.0) % 12) * 16.0
	$Sprite.position.y = sin(time * 3.0) * 1.5

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	set_deferred("monitoring", false)
	collected.emit()
	set_process(false)
	var tween := create_tween().set_parallel(true)
	tween.tween_property($Sprite, "position:y", -18.0, 0.22).set_ease(Tween.EASE_OUT)
	tween.tween_property($Sprite, "modulate:a", 0.0, 0.22)
	tween.chain().tween_callback(queue_free)
