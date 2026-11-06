extends CharacterBody2D

signal died

const SPEED = 120.0
const JUMP_VELOCITY = -360.0
const JUMP_SOUND := preload("res://assets/sounds/jump.wav")
var has_fallen := false
var jump_audio_player: AudioStreamPlayer

func _ready() -> void:
	jump_audio_player = AudioStreamPlayer.new()
	jump_audio_player.stream = JUMP_SOUND
	add_child(jump_audio_player)

func _physics_process(delta: float) -> void:
	if has_fallen:
		return

	if not is_on_floor():
		velocity.y = min(velocity.y + get_gravity().y * delta, 700.0)

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_audio_player.play()

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, 900.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)

	move_and_slide()

	if global_position.y > 520:
		has_fallen = true
		died.emit()
