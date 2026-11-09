extends CanvasLayer
## On-screen touch controls for phones/tablets (native and mobile browsers).
## Left side of the screen = move (slide your thumb between the arrows),
## right side = jump, small button top-right = restart level.
## Drives the same input actions the keyboard uses, so gameplay code is untouched.

signal restart_pressed

const MOVE_LEFT := "ui_left"
const MOVE_RIGHT := "ui_right"
const JUMP := "ui_accept"

const COL_FILL := Color(0.13, 0.11, 0.27, 0.45)
const COL_FILL_ON := Color(1.0, 0.94, 0.66, 0.55)
const COL_RIM := Color(1.0, 0.94, 0.66, 0.85)
const COL_ICON := Color(1, 1, 1, 0.95)
const COL_ICON_ON := Color(0.13, 0.11, 0.27, 1.0)

## Show controls only while a level is being played.
var active := false:
	set(value):
		active = value
		_update_visibility()
		if not active:
			_release_all()

var _touch_seen := false
var _move_fingers := {}   # finger index -> -1 / 0 / 1
var _jump_fingers := {}   # finger index -> true
var _restart_finger := -1
var _dir := 0
var _jumping := false

var _canvas: Node2D
var _r := 64.0
var _left_c := Vector2.ZERO
var _right_c := Vector2.ZERO
var _jump_c := Vector2.ZERO
var _jump_r := 80.0
var _restart_c := Vector2.ZERO
var _restart_r := 32.0

func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	_canvas = Node2D.new()
	_canvas.draw.connect(_draw_controls)
	add_child(_canvas)
	_touch_seen = DisplayServer.is_touchscreen_available()
	get_viewport().size_changed.connect(_layout)
	_layout()
	_update_visibility()

func _update_visibility() -> void:
	visible = active and _touch_seen

func _layout() -> void:
	var vs := get_viewport().get_visible_rect().size
	_r = clampf(minf(vs.x, vs.y) * 0.105, 44.0, 96.0)
	var m := _r * 0.45
	_left_c = Vector2(m + _r, vs.y - m - _r)
	_right_c = _left_c + Vector2(_r * 2.35, 0)
	_jump_r = _r * 1.25
	_jump_c = Vector2(vs.x - m - _jump_r, vs.y - m - _jump_r)
	_restart_r = _r * 0.5
	_restart_c = Vector2(vs.x - m - _restart_r, m + _restart_r)
	if _canvas:
		_canvas.queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if not _touch_seen:
			_touch_seen = true
			_update_visibility()
		if not visible:
			return
		var idx: int = event.index
		if event.pressed:
			_on_finger_down(idx, event.position)
		else:
			_on_finger_up(idx)
		_apply()
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and visible:
		if _move_fingers.has(event.index):
			_move_fingers[event.index] = _dir_for(event.position)
			_apply()
		get_viewport().set_input_as_handled()

func _on_finger_down(idx: int, pos: Vector2) -> void:
	var vs := get_viewport().get_visible_rect().size
	if pos.distance_to(_restart_c) <= _restart_r * 1.5:
		_restart_finger = idx
	elif pos.x < vs.x * 0.5:
		_move_fingers[idx] = _dir_for(pos)
	else:
		_jump_fingers[idx] = true

func _on_finger_up(idx: int) -> void:
	_move_fingers.erase(idx)
	_jump_fingers.erase(idx)
	if idx == _restart_finger:
		_restart_finger = -1
		restart_pressed.emit()

func _dir_for(pos: Vector2) -> int:
	# Split point between the two arrows; small dead zone so resting a thumb in
	# the middle doesn't jitter.
	var mid := (_left_c.x + _right_c.x) * 0.5
	if pos.x < mid - _r * 0.15:
		return -1
	if pos.x > mid + _r * 0.15:
		return 1
	return 0

func _apply() -> void:
	var dir := 0
	for d in _move_fingers.values():
		if d != 0:
			dir = d
	if dir != _dir:
		_dir = dir
		_set_action(MOVE_LEFT, dir < 0)
		_set_action(MOVE_RIGHT, dir > 0)
	var jumping := not _jump_fingers.is_empty()
	if jumping != _jumping:
		_jumping = jumping
		_set_action(JUMP, jumping)
	_canvas.queue_redraw()

func _set_action(action: StringName, on: bool) -> void:
	if on:
		Input.action_press(action)
	else:
		Input.action_release(action)

func _release_all() -> void:
	_move_fingers.clear()
	_jump_fingers.clear()
	_restart_finger = -1
	if _canvas:
		_apply()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_release_all()

# --- drawing -----------------------------------------------------------------

func _draw_controls() -> void:
	_draw_button(_left_c, _r, _dir < 0)
	_draw_arrow(_left_c, _r * 0.42, -1, _dir < 0)
	_draw_button(_right_c, _r, _dir > 0)
	_draw_arrow(_right_c, _r * 0.42, 1, _dir > 0)

	_draw_button(_jump_c, _jump_r, _jumping)
	var ic := COL_ICON_ON if _jumping else COL_ICON
	var s := _jump_r * 0.36
	var c := _jump_c + Vector2(0, -s * 0.15)
	_canvas.draw_colored_polygon(PackedVector2Array([
		c + Vector2(0, -s), c + Vector2(s, s * 0.3), c + Vector2(-s, s * 0.3)]), ic)
	_canvas.draw_rect(Rect2(c + Vector2(-s * 0.35, s * 0.3), Vector2(s * 0.7, s * 0.75)), ic)

	var pressed := _restart_finger != -1
	_draw_button(_restart_c, _restart_r, pressed)
	ic = COL_ICON_ON if pressed else COL_ICON
	var rr := _restart_r * 0.5
	_canvas.draw_arc(_restart_c, rr, deg_to_rad(-60), deg_to_rad(230), 24, ic, maxf(3.0, _restart_r * 0.13), true)
	var tip := _restart_c + Vector2.from_angle(deg_to_rad(-60)) * rr
	var t := rr * 0.6
	_canvas.draw_colored_polygon(PackedVector2Array([
		tip + Vector2(-t * 0.2, -t), tip + Vector2(t * 0.9, t * 0.1), tip + Vector2(-t * 0.5, t * 0.6)]), ic)

func _draw_button(center: Vector2, radius: float, on: bool) -> void:
	_canvas.draw_circle(center, radius, COL_FILL_ON if on else COL_FILL)
	_canvas.draw_arc(center, radius, 0.0, TAU, 48, COL_RIM, maxf(3.0, radius * 0.06), true)

func _draw_arrow(center: Vector2, size: float, dir: int, on: bool) -> void:
	var d := float(dir)
	_canvas.draw_colored_polygon(PackedVector2Array([
		center + Vector2(d * size, 0),
		center + Vector2(-d * size * 0.7, -size),
		center + Vector2(-d * size * 0.7, size)]), COL_ICON_ON if on else COL_ICON)
