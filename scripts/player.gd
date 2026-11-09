extends CharacterBody2D

signal died

const SPEED = 120.0
const JUMP_VELOCITY = -360.0
const COYOTE_TIME := 0.1
const JUMP_BUFFER := 0.12
const KNIGHT_TEX := preload("res://assets/sprites/knight.png")
const JUMP_SOUND := preload("res://assets/sounds/jump.wav")

var death_y := 520.0
var has_fallen := false
var jump_audio_player: AudioStreamPlayer
var coyote := 0.0
var jump_buffer := 0.0
var rush_time := 0.0
var was_on_floor := true
var jumping := false  # true while rising from a normal jump (short-hop applies)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	jump_audio_player = AudioStreamPlayer.new()
	jump_audio_player.stream = JUMP_SOUND
	add_child(jump_audio_player)
	sprite.sprite_frames = _build_frames()
	sprite.play("idle")

func _build_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	var anims := {
		"idle": [[0, 0], [1, 0], [2, 0], [3, 0]],
		"run": [[0, 2], [1, 2], [2, 2], [3, 2], [4, 2], [5, 2], [6, 2], [7, 2], [0, 3], [1, 3], [2, 3], [3, 3], [4, 3], [5, 3], [6, 3], [7, 3]],
		"jump": [[1, 5]],
		"fall": [[2, 5]],
		"flip": [[3, 5], [4, 5], [5, 5], [0, 5]],
	}
	for anim_name in anims:
		frames.add_animation(anim_name)
		frames.set_animation_speed(anim_name, 18.0 if anim_name == "run" else (14.0 if anim_name == "flip" else 8.0))
		frames.set_animation_loop(anim_name, anim_name != "flip")
		for cell in anims[anim_name]:
			var tex := AtlasTexture.new()
			tex.atlas = KNIGHT_TEX
			tex.region = Rect2(cell[0] * 32, cell[1] * 32, 32, 32)
			frames.add_frame(anim_name, tex)
	return frames

func _physics_process(delta: float) -> void:
	if has_fallen:
		return
	var rushing := rush_time > 0.0
	if rushing:
		rush_time -= delta
		sprite.modulate = Color.from_hsv(fmod(Time.get_ticks_msec() / 400.0, 1.0), 0.45, 1.0)
		if rush_time <= 0.0:
			sprite.modulate = Color.WHITE

	if not is_on_floor():
		velocity.y = min(velocity.y + get_gravity().y * delta, 700.0)
		coyote -= delta
	else:
		coyote = COYOTE_TIME

	jump_buffer -= delta
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up"):
		jump_buffer = JUMP_BUFFER
	if jump_buffer > 0.0 and coyote > 0.0:
		velocity.y = JUMP_VELOCITY * (1.18 if rushing else 1.0)
		jump_buffer = 0.0
		coyote = 0.0
		jump_audio_player.pitch_scale = randf_range(0.95, 1.1)
		jump_audio_player.play()
		_squash(Vector2(0.75, 1.3))
		jumping = true
	# let go early for a short hop
	var holding := Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_up")
	if jumping and velocity.y < -120.0 and not holding:
		velocity.y = -120.0

	var top_speed := SPEED * (1.5 if rushing else 1.0)
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * top_speed, 900.0 * delta)
		sprite.flip_h = direction < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)

	move_and_slide()

	for i in get_slide_collision_count():
		var hit := get_slide_collision(i)
		var other := hit.get_collider()
		if other and other.has_method("player_touched"):
			other.player_touched(self, hit.get_normal())

	var on_floor := is_on_floor()
	if on_floor and not was_on_floor:
		_squash(Vector2(1.3, 0.75))
	was_on_floor = on_floor
	if velocity.y >= 0.0:
		jumping = false
	_animate(on_floor)

	if global_position.y > death_y:
		has_fallen = true
		died.emit()

func _animate(on_floor: bool) -> void:
	if not on_floor:
		if sprite.animation == "flip" and sprite.is_playing():
			return
		sprite.play("jump" if velocity.y < 0.0 else "fall")
	elif absf(velocity.x) > 10.0:
		sprite.play("run")
	else:
		sprite.play("idle")

func _squash(amount: Vector2) -> void:
	var tween := create_tween()
	sprite.scale = amount
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

## Called by bounce mushrooms.
func bounce(strength: float) -> void:
	velocity.y = -strength * (1.12 if rush_time > 0.0 else 1.0)
	jumping = false
	coyote = 0.0
	sprite.play("flip")
	_squash(Vector2(0.6, 1.45))

## Called by fruit.
func sugar_rush(duration: float) -> void:
	rush_time = duration
