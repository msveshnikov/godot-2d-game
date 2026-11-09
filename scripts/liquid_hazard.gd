@tool
extends Area2D
## Invisible kill zone just under a liquid surface.

signal killed(reason: String)

@export var death_reason := "SPLASH!"

var _rect := Rect2()

func setup(rect: Rect2) -> void:
	_rect = rect

func _ready() -> void:
	add_to_group("level_events")
	collision_layer = 0
	collision_mask = 1
	position = _rect.position + _rect.size * 0.5
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = _rect.size
	shape.shape = box
	add_child(shape)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		killed.emit(death_reason)
