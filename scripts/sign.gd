extends Node2D

@export var sign_text := "KEEP OUT!"

@onready var label: Label = $Label

func _ready() -> void:
	label.text = sign_text
