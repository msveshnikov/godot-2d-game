extends AnimatableBody2D

@export var travel := Vector2(0, 40)
@export var cycles_per_second := 0.3

var origin := Vector2.ZERO
var time := 0.0

func _ready() -> void:
	origin = position

func _physics_process(delta: float) -> void:
	time += delta
	position = origin + travel * sin(time * TAU * cycles_per_second)
