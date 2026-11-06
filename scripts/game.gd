extends Node2D

const PLATFORM_TEXTURE := preload("res://assets/sprites/platforms.png")
const WORLD_TEXTURE := preload("res://assets/sprites/world_tileset.png")
const PIXEL_FONT := preload("res://assets/fonts/PixelOperator8-Bold.ttf")
const COIN_SOUND := preload("res://assets/sounds/coin.wav")
const HURT_SOUND := preload("res://assets/sounds/hurt.wav")
const POWER_UP_SOUND := preload("res://assets/sounds/power_up.wav")
const EXPLOSION_SOUND := preload("res://assets/sounds/explosion.wav")

const LEVELS := [
	{
		"name": "Biscuit Woods",
		"sky": Color("#75ddff"),
		"far_hills": Color("#a7f0d1"),
		"near_hills": Color("#54c887"),
		"platform_row": 0,
		"tile_column": 0,
		"sun": Color("#ffe56b"),
		"width": 960,
		"jokes": [
			{"position": Vector2(270, 165), "text": "BERRY NICE"},
			{"position": Vector2(610, 95), "text": "SLO-MO ZONE"},
		],
		"spawn": Vector2(70, 220),
		"goal": Vector2(820, 110),
		"platforms": [
			{"x": 0, "y": 300, "w": 180, "h": 22},
			{"x": 230, "y": 260, "w": 170, "h": 18},
			{"x": 430, "y": 220, "w": 170, "h": 18},
			{"x": 640, "y": 180, "w": 150, "h": 18},
			{"x": 780, "y": 140, "w": 100, "h": 18},
		],
		"coins": [
			Vector2(120, 250),
			Vector2(300, 220),
			Vector2(500, 180),
			Vector2(700, 140),
			Vector2(825, 90),
		],
		"enemies": [
			{"x": 300, "y": 250, "left": 240, "right": 370, "speed": 42, "kind": "green"},
		],
		"moving": [
			{"x": 181, "y": 280, "w": 48, "range": 8, "speed": 1.4, "axis": "vertical"},
		],
	},
	{
		"name": "Wobblepop Bridge",
		"sky": Color("#ffb183"),
		"far_hills": Color("#d990c6"),
		"near_hills": Color("#8464b2"),
		"platform_row": 1,
		"tile_column": 2,
		"sun": Color("#fff078"),
		"width": 1080,
		"jokes": [
			{"position": Vector2(300, 155), "text": "BRIDGE-ish"},
			{"position": Vector2(700, 75), "text": "NO REFUNDS"},
		],
		"spawn": Vector2(60, 220),
		"goal": Vector2(880, 90),
		"platforms": [
			{"x": 0, "y": 300, "w": 150, "h": 22},
			{"x": 200, "y": 250, "w": 140, "h": 18},
			{"x": 380, "y": 210, "w": 140, "h": 18},
			{"x": 560, "y": 170, "w": 140, "h": 18},
			{"x": 735, "y": 130, "w": 130, "h": 18},
			{"x": 900, "y": 95, "w": 80, "h": 18},
		],
		"coins": [
			Vector2(80, 250),
			Vector2(250, 210),
			Vector2(440, 170),
			Vector2(620, 130),
			Vector2(790, 90),
			Vector2(930, 55),
		],
		"enemies": [
			{"x": 420, "y": 200, "left": 390, "right": 500, "speed": 56, "kind": "purple"},
			{"x": 790, "y": 120, "left": 750, "right": 850, "speed": 64, "kind": "green"},
		],
		"moving": [
			{"x": 336, "y": 230, "w": 48, "range": 8, "speed": 1.2, "axis": "vertical"},
		],
	},
	{
		"name": "Gumdrop Heights",
		"sky": Color("#7166cf"),
		"far_hills": Color("#b9a2ff"),
		"near_hills": Color("#f18fc7"),
		"platform_row": 3,
		"tile_column": 5,
		"sun": Color("#fff7ad"),
		"width": 1150,
		"jokes": [
			{"position": Vector2(330, 145), "text": "CLOUD STORAGE"},
			{"position": Vector2(760, 40), "text": "BOSS? ON BREAK"},
		],
		"spawn": Vector2(60, 250),
		"goal": Vector2(930, 70),
		"platforms": [
			{"x": 0, "y": 320, "w": 140, "h": 22},
			{"x": 190, "y": 270, "w": 120, "h": 18},
			{"x": 340, "y": 230, "w": 120, "h": 18},
			{"x": 500, "y": 190, "w": 120, "h": 18},
			{"x": 660, "y": 150, "w": 120, "h": 18},
			{"x": 820, "y": 110, "w": 120, "h": 18},
			{"x": 980, "y": 70, "w": 70, "h": 18},
		],
		"coins": [
			Vector2(90, 280),
			Vector2(240, 230),
			Vector2(390, 190),
			Vector2(555, 150),
			Vector2(715, 110),
			Vector2(870, 70),
			Vector2(1015, 30),
		],
		"enemies": [
			{"x": 400, "y": 220, "left": 350, "right": 440, "speed": 70, "kind": "purple"},
			{"x": 870, "y": 100, "left": 835, "right": 925, "speed": 76, "kind": "green"},
		],
		"moving": [
			{"x": 456, "y": 210, "w": 48, "range": 8, "speed": 1.6, "axis": "vertical"},
			{"x": 776, "y": 130, "w": 48, "range": 8, "speed": 1.3, "axis": "vertical"},
		],
	},
	{
		"name": "Cloudtop Circus",
		"sky": Color("#75cfff"),
		"far_hills": Color("#d8c2ff"),
		"near_hills": Color("#ff9ed6"),
		"platform_row": 3,
		"tile_column": 7,
		"sun": Color("#fff5a8"),
		"width": 1180,
		"jokes": [
			{"position": Vector2(300, 150), "text": "CLOUD STORAGE"},
			{"position": Vector2(850, 90), "text": "HONK IF YOU FALL"},
		],
		"spawn": Vector2(60, 280),
		"goal": Vector2(1115, 65),
		"platforms": [
			{"x": 0, "y": 300, "w": 135, "h": 22},
			{"x": 170, "y": 270, "w": 100, "h": 18},
			{"x": 315, "y": 240, "w": 100, "h": 18},
			{"x": 465, "y": 210, "w": 100, "h": 18},
			{"x": 615, "y": 180, "w": 100, "h": 18},
			{"x": 765, "y": 150, "w": 100, "h": 18},
			{"x": 915, "y": 120, "w": 100, "h": 18},
			{"x": 1065, "y": 90, "w": 110, "h": 18},
		],
		"coins": [
			Vector2(65, 264), Vector2(215, 234), Vector2(360, 204),
			Vector2(510, 174), Vector2(660, 144), Vector2(810, 114),
			Vector2(960, 84), Vector2(1120, 54),
		],
		"enemies": [
			{"x": 350, "y": 230, "left": 330, "right": 400, "speed": 72, "kind": "green"},
			{"x": 815, "y": 140, "left": 780, "right": 855, "speed": 80, "kind": "purple"},
		],
		"moving": [
			{"x": 416, "y": 225, "w": 48, "range": 8, "speed": 1.8, "axis": "vertical"},
			{"x": 716, "y": 165, "w": 48, "range": 18, "speed": 1.4, "axis": "horizontal"},
		],
	},
	{
		"name": "Mooncheese Mine",
		"sky": Color("#293162"),
		"far_hills": Color("#5857a0"),
		"near_hills": Color("#9562b0"),
		"platform_row": 1,
		"tile_column": 8,
		"sun": Color("#fff1b5"),
		"width": 1200,
		"jokes": [
			{"position": Vector2(320, 145), "text": "MOON MADE OF CHEESE"},
			{"position": Vector2(870, 95), "text": "MINE YOUR BUSINESS"},
		],
		"spawn": Vector2(60, 280),
		"goal": Vector2(1140, 55),
		"platforms": [
			{"x": 0, "y": 300, "w": 135, "h": 22},
			{"x": 170, "y": 270, "w": 100, "h": 18},
			{"x": 315, "y": 240, "w": 100, "h": 18},
			{"x": 465, "y": 210, "w": 100, "h": 18},
			{"x": 615, "y": 180, "w": 100, "h": 18},
			{"x": 765, "y": 150, "w": 100, "h": 18},
			{"x": 915, "y": 120, "w": 100, "h": 18},
			{"x": 1065, "y": 90, "w": 120, "h": 18},
		],
		"coins": [
			Vector2(65, 264), Vector2(215, 234), Vector2(360, 204),
			Vector2(510, 174), Vector2(660, 144), Vector2(810, 114),
			Vector2(960, 84), Vector2(1120, 54),
		],
		"enemies": [
			{"x": 360, "y": 230, "left": 330, "right": 400, "speed": 84, "kind": "purple"},
			{"x": 810, "y": 140, "left": 780, "right": 850, "speed": 90, "kind": "green"},
			{"x": 1110, "y": 80, "left": 1080, "right": 1165, "speed": 94, "kind": "purple"},
		],
		"moving": [
			{"x": 416, "y": 225, "w": 48, "range": 8, "speed": 1.7, "axis": "vertical"},
			{"x": 716, "y": 165, "w": 48, "range": 18, "speed": 1.9, "axis": "horizontal"},
		],
	},
	{
		"name": "The Big Slime",
		"sky": Color("#332755"),
		"far_hills": Color("#624277"),
		"near_hills": Color("#a44890"),
		"platform_row": 2,
		"tile_column": 4,
		"sun": Color("#ff9de1"),
		"width": 980,
		"jokes": [
			{"position": Vector2(300, 210), "text": "IT'S A BIG BABY"},
			{"position": Vector2(730, 210), "text": "STOMP RESPONSIBLY"},
		],
		"spawn": Vector2(70, 300),
		"boss": true,
		"platforms": [
			{"x": 0, "y": 320, "w": 980, "h": 22},
			{"x": 185, "y": 255, "w": 75, "h": 18},
			{"x": 720, "y": 255, "w": 75, "h": 18},
		],
		"coins": [
			Vector2(215, 223), Vector2(760, 223), Vector2(120, 284),
			Vector2(860, 284),
		],
		"enemies": [],
		"moving": [],
	}
]

var current_level_index := 0
var world: Node2D
var player: CharacterBody2D
var goal_area: Area2D
var level_label: Label
var status_label: Label
var collected_coins_this_level := 0
var total_coins_this_level := 0
var game_won := false
var music_player: AudioStreamPlayer
var title_layer: CanvasLayer
var boss: Area2D
var boss_hits := 0
var boss_hit_cooldown := 0.0
var boss_health_bar: ProgressBar
var level_time := 0.0
var moving_platforms: Array[Dictionary] = []
var game_started := false
var level_transitioning := false
var level_generation := 0
var patrolling_enemies: Array[Area2D] = []

func _ready() -> void:
	_clear_scene_contents()
	world = Node2D.new()
	world.name = "World"
	add_child(world)

	_create_hud()
	_setup_music()
	_create_background(LEVELS[0])
	_create_scenery(LEVELS[0])
	for platform in LEVELS[0]["platforms"]:
		_create_platform(platform["x"], platform["y"], platform["w"], platform["h"])
	_create_title_screen()

func _clear_scene_contents() -> void:
	for child in get_children():
		child.queue_free()

func _create_hud() -> void:
	var hud := CanvasLayer.new()
	hud.name = "HUD"
	add_child(hud)

	var panel := Panel.new()
	panel.position = Vector2(10, 8)
	panel.size = Vector2(350, 70)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#28234f")
	panel_style.bg_color.a = 0.88
	panel_style.border_color = Color("#fff1a8")
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", panel_style)
	hud.add_child(panel)

	level_label = Label.new()
	level_label.position = Vector2(20, 12)
	level_label.add_theme_font_override("font", PIXEL_FONT)
	level_label.add_theme_font_size_override("font_size", 18)
	level_label.add_theme_color_override("font_color", Color("#fff1a8"))
	level_label.add_theme_color_override("font_outline_color", Color("#28234f"))
	level_label.add_theme_constant_override("outline_size", 3)
	hud.add_child(level_label)

	status_label = Label.new()
	status_label.position = Vector2(20, 40)
	status_label.add_theme_font_override("font", PIXEL_FONT)
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.add_theme_color_override("font_color", Color("#ffffff"))
	status_label.add_theme_color_override("font_outline_color", Color("#28234f"))
	status_label.add_theme_constant_override("outline_size", 2)
	hud.add_child(status_label)

	boss_health_bar = ProgressBar.new()
	boss_health_bar.position = Vector2(20, 82)
	boss_health_bar.size = Vector2(300, 18)
	boss_health_bar.max_value = 4
	boss_health_bar.show_percentage = false
	boss_health_bar.visible = false
	var health_bg := StyleBoxFlat.new()
	health_bg.bg_color = Color("#302044")
	health_bg.border_color = Color("#fff1a8")
	health_bg.set_border_width_all(2)
	boss_health_bar.add_theme_stylebox_override("background", health_bg)
	var health_fill := StyleBoxFlat.new()
	health_fill.bg_color = Color("#ff4f91")
	health_fill.set_corner_radius_all(3)
	boss_health_bar.add_theme_stylebox_override("fill", health_fill)
	hud.add_child(boss_health_bar)

func _create_title_screen() -> void:
	title_layer = CanvasLayer.new()
	title_layer.layer = 10
	add_child(title_layer)

	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color("#182348")
	shade.color.a = 0.58
	title_layer.add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title_layer.add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(440, 370)
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color("#332755")
	card_style.border_color = Color("#fff1a8")
	card_style.set_border_width_all(4)
	card_style.set_corner_radius_all(18)
	card_style.content_margin_left = 28
	card_style.content_margin_right = 28
	card_style.content_margin_top = 26
	card_style.content_margin_bottom = 24
	card.add_theme_stylebox_override("panel", card_style)
	center.add_child(card)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 13)
	card.add_child(layout)

	var title := Label.new()
	title.text = "KNIGHT OF THE\nSNACK REALM"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", PIXEL_FONT)
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("#fff17b"))
	title.add_theme_color_override("font_outline_color", Color("#812e83"))
	title.add_theme_constant_override("outline_size", 6)
	layout.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Six silly worlds. One very large slime."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_override("font", PIXEL_FONT)
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", Color("#ffffff"))
	layout.add_child(subtitle)

	var instructions := Label.new()
	instructions.text = "MOVE  ← →     JUMP  SPACE / ↑\nSTOMP slimes from above. Ride the wobbly platforms.\nCollect shiny coins. Do not lick the moon."
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instructions.add_theme_font_override("font", PIXEL_FONT)
	instructions.add_theme_font_size_override("font_size", 10)
	instructions.add_theme_color_override("font_color", Color("#dffbff"))
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(instructions)

	var start_button := Button.new()
	start_button.text = "START THE SNACK QUEST!"
	start_button.custom_minimum_size = Vector2(0, 52)
	start_button.add_theme_font_override("font", PIXEL_FONT)
	start_button.add_theme_font_size_override("font_size", 14)
	start_button.add_theme_color_override("font_color", Color("#39204a"))
	start_button.add_theme_stylebox_override("normal", _button_style(Color("#a8f05d"), Color("#faffb0")))
	start_button.add_theme_stylebox_override("hover", _button_style(Color("#d4ff78"), Color("#ffffff")))
	start_button.add_theme_stylebox_override("pressed", _button_style(Color("#73d997"), Color("#fff1a8")))
	start_button.pressed.connect(_start_game)
	layout.add_child(start_button)

	var footer := Label.new()
	footer.text = "ENTER: start   ·   ←/→: move   ·   SPACE: jump"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_override("font", PIXEL_FONT)
	footer.add_theme_font_size_override("font_size", 9)
	footer.add_theme_color_override("font_color", Color("#e7d8ff"))
	layout.add_child(footer)

func _button_style(fill_color: Color, outline_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = outline_color
	style.set_border_width_all(3)
	style.set_corner_radius_all(10)
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func _start_game() -> void:
	if game_started:
		return
	game_started = true
	title_layer.visible = false
	load_level(0)

func _setup_music() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.stream = preload("res://assets/music/time_for_adventure.mp3")
	music_player.volume_db = -10.0
	music_player.autoplay = true
	add_child(music_player)
	music_player.play()

func _play_sfx(stream: AudioStream) -> void:
	var sound_player := AudioStreamPlayer.new()
	sound_player.stream = stream
	sound_player.finished.connect(sound_player.queue_free)
	add_child(sound_player)
	sound_player.play()

func load_level(level_index: int) -> void:
	if level_index < 0 or level_index >= LEVELS.size():
		push_error("Requested level index is out of range: %d" % level_index)
		return
	level_generation += 1
	current_level_index = level_index
	game_won = false
	level_transitioning = false
	goal_area = null
	collected_coins_this_level = 0
	level_time = 0.0
	boss_hits = 0
	boss_hit_cooldown = 0.0
	boss = null
	moving_platforms.clear()
	patrolling_enemies.clear()
	boss_health_bar.visible = false
	if is_instance_valid(player):
		player.queue_free()
	for child in world.get_children():
		child.queue_free()

	var level_data: Dictionary = LEVELS[level_index]
	total_coins_this_level = level_data["coins"].size()

	_create_background(level_data)
	_create_scenery(level_data)

	for platform in level_data["platforms"]:
		_create_platform(platform["x"], platform["y"], platform["w"], platform["h"])

	for platform_data in level_data["moving"]:
		_create_moving_platform(platform_data)

	for enemy_data in level_data["enemies"]:
		_create_enemy(enemy_data)

	for coin_position in level_data["coins"]:
		_create_coin(coin_position)

	player = preload("res://scenes/player.tscn").instantiate()
	player.position = level_data["spawn"]
	player.name = "Player"
	player.died.connect(_on_player_died)
	var camera := Camera2D.new()
	camera.name = "Camera2D"
	camera.zoom = Vector2(1.7, 1.7)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 6.0
	camera.limit_left = -60
	camera.limit_right = int(level_data["width"]) + 80
	camera.limit_top = -180
	camera.limit_bottom = 460
	player.add_child(camera)
	world.add_child(player)

	if level_data.get("boss", false):
		_create_boss()
	else:
		_create_goal(level_data["goal"])

	level_label.text = "WORLD %d / %d  ·  %s" % [level_index + 1, LEVELS.size(), level_data["name"].to_upper()]
	_update_coin_status()

func _create_goal(goal_position: Vector2) -> void:
	goal_area = Area2D.new()
	goal_area.name = "Goal"
	goal_area.position = goal_position
	goal_area.collision_layer = 1
	goal_area.collision_mask = 1

	var goal_shape := CollisionShape2D.new()
	var goal_rect := RectangleShape2D.new()
	goal_rect.size = Vector2(22, 46)
	goal_shape.shape = goal_rect
	goal_area.add_child(goal_shape)

	var pole := Polygon2D.new()
	pole.position = Vector2(-9, -23)
	pole.polygon = PackedVector2Array([
		Vector2(-2, 0), Vector2(2, 0), Vector2(2, 46), Vector2(-2, 46)
	])
	pole.color = Color("#fff2c2")
	goal_area.add_child(pole)

	var flag := Polygon2D.new()
	flag.position = Vector2(-7, -21)
	flag.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(29, 8), Vector2(0, 18)
	])
	flag.color = Color("#ff557d")
	goal_area.add_child(flag)
	goal_area.body_entered.connect(_on_goal_reached)
	world.add_child(goal_area)

func _physics_process(delta: float) -> void:
	if not game_started:
		return
	level_time += delta
	for platform_data in moving_platforms:
		var moving_body: Node2D = platform_data["node"]
		if not is_instance_valid(moving_body):
			continue
		var offset: float = sin(
			level_time * float(platform_data["speed"]) + float(platform_data["phase"])
		) * float(platform_data["range"])
		var motion := Vector2.ZERO
		var origin: Vector2 = platform_data["origin"]
		if platform_data["axis"] == "vertical":
			motion.y = offset
		else:
			motion.x = offset
		moving_body.position = origin + motion

	for enemy in patrolling_enemies:
		if not is_instance_valid(enemy):
			continue
		var direction: float = enemy.get_meta("direction")
		var speed: float = enemy.get_meta("speed")
		enemy.position.x += direction * speed * delta
		if enemy.position.x < enemy.get_meta("left"):
			enemy.position.x = enemy.get_meta("left")
			enemy.set_meta("direction", 1.0)
			enemy.scale.x = 1.0
		elif enemy.position.x > enemy.get_meta("right"):
			enemy.position.x = enemy.get_meta("right")
			enemy.set_meta("direction", -1.0)
			enemy.scale.x = -1.0

	if boss_hit_cooldown > 0.0:
		boss_hit_cooldown = maxf(0.0, boss_hit_cooldown - delta)
	if is_instance_valid(boss):
		boss.position.x = boss.get_meta("home_x") + sin(level_time * 1.25) * 125.0
		boss.position.y = boss.get_meta("home_y") + absf(sin(level_time * 2.0)) * 14.0

func _create_boss() -> void:
	boss = Area2D.new()
	boss.name = "BigSlimeBoss"
	boss.position = Vector2(490, 292)
	boss.collision_layer = 1
	boss.collision_mask = 1
	boss.set_meta("home_x", boss.position.x)
	boss.set_meta("home_y", boss.position.y)

	var boss_shape := CollisionShape2D.new()
	var boss_rect := RectangleShape2D.new()
	boss_rect.size = Vector2(64, 48)
	boss_shape.shape = boss_rect
	boss.add_child(boss_shape)
	var boss_sprite := _make_slime_sprite("purple")
	boss_sprite.scale = Vector2(2.5, 2.5)
	boss_sprite.position.y = -4
	boss.add_child(boss_sprite)
	boss.body_entered.connect(_on_boss_body_entered)
	world.add_child(boss)

	boss_health_bar.max_value = 4
	boss_health_bar.value = 4
	boss_health_bar.visible = true
	status_label.text = "THE BIG SLIME! Bounce on its head 4 times!"

func _on_boss_body_entered(body: Node2D) -> void:
	if body != player or not is_instance_valid(boss) or boss_hit_cooldown > 0.0:
		return
	if player.velocity.y > 40.0 and player.global_position.y < boss.global_position.y + 36.0:
		boss_hits += 1
		boss_hit_cooldown = 0.85
		player.velocity.y = -300.0
		_play_sfx(POWER_UP_SOUND)
		boss_health_bar.value = 4 - boss_hits
		boss.modulate = Color("#fff5a8")
		status_label.text = ["BONK! That tickled!", "BONK! Slime wobble!", "BONK! One more!"][mini(boss_hits - 1, 2)]
		_restore_boss_color()
		if boss_hits >= 4:
			boss.queue_free()
			game_won = true
			status_label.text = "THE SLIME SURRENDERS! Press R for another snack quest."
			_play_sfx(EXPLOSION_SOUND)
	else:
		_on_player_died()

func _restore_boss_color() -> void:
	await get_tree().create_timer(0.16).timeout
	if is_instance_valid(boss):
		boss.modulate = Color.WHITE

func _create_background(level_data: Dictionary) -> void:
	var background := Node2D.new()
	background.name = "ColorfulBackground"
	background.z_index = -20
	world.add_child(background)

	var sky := Polygon2D.new()
	sky.polygon = PackedVector2Array([
		Vector2(-500, -500), Vector2(1600, -500),
		Vector2(1600, 700), Vector2(-500, 700)
	])
	sky.color = level_data["sky"]
	background.add_child(sky)

	var sun_position := Vector2(float(level_data["width"]) * 0.82, 30)
	_add_circle(background, sun_position, 34, level_data["sun"])
	_add_circle(background, sun_position, 25, Color("#fffbd6"))

	var far_hills := Polygon2D.new()
	far_hills.polygon = PackedVector2Array([
		Vector2(-500, 250), Vector2(-350, 175), Vector2(-190, 225),
		Vector2(-30, 145), Vector2(140, 215), Vector2(310, 155),
		Vector2(480, 225), Vector2(650, 150), Vector2(820, 220),
		Vector2(1010, 155), Vector2(1200, 220), Vector2(1400, 160),
		Vector2(1600, 230), Vector2(1600, 700), Vector2(-500, 700)
	])
	far_hills.color = level_data["far_hills"]
	background.add_child(far_hills)

	var near_hills := Polygon2D.new()
	near_hills.polygon = PackedVector2Array([
		Vector2(-500, 320), Vector2(-330, 245), Vector2(-160, 300),
		Vector2(20, 230), Vector2(210, 305), Vector2(390, 240),
		Vector2(580, 310), Vector2(760, 225), Vector2(940, 300),
		Vector2(1120, 235), Vector2(1320, 305), Vector2(1470, 245),
		Vector2(1600, 300), Vector2(1600, 700), Vector2(-500, 700)
	])
	near_hills.color = level_data["near_hills"]
	background.add_child(near_hills)

	for cloud_position in [Vector2(100, 55), Vector2(390, 85), Vector2(690, 45), Vector2(900, 120)]:
		_create_cloud(background, cloud_position)

	if current_level_index >= 4:
		var star_positions := [
			Vector2(70, 38), Vector2(175, 112), Vector2(265, 50), Vector2(440, 95),
			Vector2(585, 42), Vector2(730, 104), Vector2(850, 34), Vector2(990, 92),
			Vector2(1150, 52), Vector2(1230, 145), Vector2(520, 125), Vector2(60, 170),
		]
		for star_index in range(star_positions.size()):
			_add_star(background, star_positions[star_index], 4.0 + float(star_index % 3), Color("#fff4b0"))

	for joke in level_data["jokes"]:
		_create_joke_sign(background, joke["position"], joke["text"])

func _add_star(parent: Node2D, center: Vector2, radius: float, color: Color) -> void:
	var star := Polygon2D.new()
	var points := PackedVector2Array()
	for i in range(8):
		var angle := -PI / 2.0 + TAU * float(i) / 8.0
		var point_radius := radius if i % 2 == 0 else radius * 0.38
		points.append(Vector2(cos(angle), sin(angle)) * point_radius)
	star.polygon = points
	star.position = center
	star.color = color
	parent.add_child(star)

func _create_scenery(level_data: Dictionary) -> void:
	var scenery := Node2D.new()
	scenery.name = "TileAndFoliageScenery"
	scenery.z_index = -3
	world.add_child(scenery)

	var world_width: int = level_data["width"]
	var tile_column: int = level_data["tile_column"]
	var tile_index := 0
	for x in range(-16, world_width + 16, 16):
		var column := tile_column
		if tile_index % 7 == 0:
			column = (tile_column + 1) % 9
		_add_atlas_tile(scenery, Vector2(x, 420), column, 16)
		_add_atlas_tile(scenery, Vector2(x, 436), column, 32)
		tile_index += 1

	var forest_props := [
		"bush", "tree", "rock", "mushroom_orange", "palm",
		"bush", "tree", "rock", "mushroom_purple", "cactus",
	]
	var dessert_props := [
		"mushroom_orange", "rock", "cactus", "bush", "mushroom_purple",
		"rock", "tree", "mushroom_orange", "bush", "palm",
	]
	var night_props := [
		"crystal", "rock", "mushroom_purple", "cactus", "crystal",
		"bush", "mushroom_orange", "rock", "crystal", "palm",
	]
	var prop_sets: Array = [forest_props, dessert_props, night_props, forest_props, night_props, dessert_props]
	var props: Array = prop_sets[current_level_index]
	var prop_index := 0
	for x in range(95, world_width, 145):
		var prop_name: String = props[prop_index % props.size()]
		var size := 1.0
		if prop_name == "tree" or prop_name == "palm":
			size = 1.35
		_create_atlas_prop(scenery, prop_name, Vector2(x, 378), size, prop_index % 2 == 1)
		prop_index += 1

	var platform_index := 0
	for platform_data in level_data["platforms"]:
		if platform_index % 2 == 0 and platform_data["w"] >= 100:
			var top_y: float = platform_data["y"]
			var prop_x: float = platform_data["x"] + platform_data["w"] - 14.0
			var kind := "rock" if platform_index % 4 == 0 else "mushroom_orange"
			_create_atlas_prop(scenery, kind, Vector2(prop_x, top_y), 0.9, platform_index % 3 == 0)
		platform_index += 1

func _add_atlas_tile(parent: Node2D, center: Vector2, atlas_column: int, atlas_row: int) -> void:
	var tile := Sprite2D.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = WORLD_TEXTURE
	atlas.region = Rect2(Vector2(atlas_column * 16, atlas_row), Vector2(16, 16))
	tile.texture = atlas
	tile.position = center
	parent.add_child(tile)

func _create_atlas_prop(
	parent: Node2D,
	kind: String,
	ground_position: Vector2,
	prop_scale: float = 1.0,
	flip_h: bool = false
) -> void:
	var region: Rect2
	match kind:
		"tree":
			region = Rect2(0, 48, 16, 48)
		"palm":
			region = Rect2(32, 80, 48, 64)
		"bush":
			region = Rect2(16, 64, 16, 16)
		"rock":
			region = Rect2(96, 80, 16, 16)
		"mushroom_orange":
			region = Rect2(112, 88, 16, 16)
		"mushroom_purple":
			region = Rect2(112, 112, 16, 16)
		"cactus":
			region = Rect2(80, 48, 16, 40)
		"crystal":
			region = Rect2(80, 48, 16, 40)
		_:
			push_error("Unknown scenery prop: %s" % kind)
			return

	var sprite := Sprite2D.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = WORLD_TEXTURE
	atlas.region = region
	sprite.texture = atlas
	sprite.centered = false
	sprite.flip_h = flip_h
	sprite.scale = Vector2(prop_scale, prop_scale)
	sprite.position = Vector2(
		ground_position.x - region.size.x * prop_scale / 2.0,
		ground_position.y - region.size.y * prop_scale
	)
	parent.add_child(sprite)

func _add_circle(parent: Node2D, center: Vector2, radius: float, color: Color) -> void:
	var circle := Polygon2D.new()
	var points := PackedVector2Array()
	for i in range(16):
		var angle := TAU * float(i) / 16.0
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	circle.polygon = points
	circle.position = center
	circle.color = color
	parent.add_child(circle)

func _create_cloud(parent: Node2D, center: Vector2) -> void:
	var cloud := Node2D.new()
	cloud.position = center
	parent.add_child(cloud)
	var cloud_color := Color("#fffaf0")
	_add_circle(cloud, Vector2(-16, 2), 12, cloud_color)
	_add_circle(cloud, Vector2(0, -4), 16, cloud_color)
	_add_circle(cloud, Vector2(18, 2), 11, cloud_color)
	var base := Polygon2D.new()
	base.polygon = PackedVector2Array([
		Vector2(-27, 1), Vector2(28, 1), Vector2(24, 9), Vector2(-23, 9)
	])
	base.color = cloud_color
	cloud.add_child(base)

func _create_joke_sign(parent: Node2D, center: Vector2, text: String) -> void:
	var sign_node := Node2D.new()
	sign_node.position = center
	parent.add_child(sign_node)

	var post := Polygon2D.new()
	post.polygon = PackedVector2Array([
		Vector2(-2, 0), Vector2(2, 0), Vector2(2, 25), Vector2(-2, 25)
	])
	post.color = Color("#85502f")
	sign_node.add_child(post)

	var board := Polygon2D.new()
	board.polygon = PackedVector2Array([
		Vector2(-34, -18), Vector2(34, -18), Vector2(34, 3), Vector2(-34, 3)
	])
	board.color = Color("#ffe77d")
	sign_node.add_child(board)

	var label := Label.new()
	label.position = Vector2(-31, -15)
	label.size = Vector2(62, 18)
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", PIXEL_FONT)
	label.add_theme_font_size_override("font_size", 7)
	label.add_theme_color_override("font_color", Color("#633c68"))
	sign_node.add_child(label)

func _create_moving_platform(platform_data: Dictionary) -> void:
	var platform: Node2D = _create_platform(
		platform_data["x"],
		platform_data["y"],
		platform_data["w"],
		16.0,
		true
	)
	moving_platforms.append({
		"node": platform,
		"origin": platform.position,
		"range": platform_data["range"],
		"speed": platform_data["speed"],
		"axis": platform_data["axis"],
		"phase": float(platform_data["x"]) * 0.013,
	})

func _create_enemy(enemy_data: Dictionary) -> void:
	var enemy := Area2D.new()
	enemy.name = "PatrolSlime"
	enemy.position = Vector2(enemy_data["x"], enemy_data["y"])
	enemy.collision_layer = 1
	enemy.collision_mask = 1
	enemy.set_meta("left", float(enemy_data["left"]))
	enemy.set_meta("right", float(enemy_data["right"]))
	enemy.set_meta("speed", float(enemy_data["speed"]))
	enemy.set_meta("direction", 1.0)
	enemy.add_to_group("patrol_enemies")

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(22, 18)
	collision.shape = shape
	enemy.add_child(collision)
	enemy.add_child(_make_slime_sprite(enemy_data["kind"]))
	enemy.body_entered.connect(_on_enemy_body_entered.bind(enemy))
	world.add_child(enemy)
	patrolling_enemies.append(enemy)

func _make_slime_sprite(kind: String) -> AnimatedSprite2D:
	var frames := SpriteFrames.new()
	frames.add_animation("wiggle")
	frames.set_animation_loop("wiggle", true)
	frames.set_animation_speed("wiggle", 7.0)
	var texture: Texture2D
	if kind == "purple":
		texture = preload("res://assets/sprites/slime_purple.png")
	else:
		texture = preload("res://assets/sprites/slime_green.png")
	for frame_index in range(4):
		var frame := AtlasTexture.new()
		frame.atlas = texture
		frame.region = Rect2(Vector2(frame_index * 24, 0), Vector2(24, 24))
		frames.add_frame("wiggle", frame)
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	sprite.animation = "wiggle"
	sprite.play()
	return sprite

func _on_enemy_body_entered(body: Node2D, enemy: Area2D) -> void:
	if body != player or not is_instance_valid(enemy):
		return
	if player.velocity.y > 45.0 and player.global_position.y < enemy.global_position.y + 24.0:
		enemy.set_deferred("monitoring", false)
		enemy.queue_free()
		player.velocity.y = -260.0
		_play_sfx(POWER_UP_SOUND)
		status_label.text = "SPLAT! The slime has become floor jam."
	else:
		_on_player_died()

func _create_platform(
	x: float,
	y: float,
	width: float,
	height: float,
	moving: bool = false
) -> Node2D:
	var platform: Node2D
	if moving:
		platform = AnimatableBody2D.new()
		(platform as AnimatableBody2D).sync_to_physics = true
	else:
		platform = StaticBody2D.new()
	platform.position = Vector2(x + width / 2.0, y + height / 2.0)

	var collision_shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(width, height)
	collision_shape.shape = rect
	platform.add_child(collision_shape)

	var tile_row: int = LEVELS[current_level_index]["platform_row"]
	var tile_column: int = LEVELS[current_level_index]["tile_column"]
	var tile_count := int(ceil(width / 16.0))
	var remaining_width := width
	var tile_left := -width / 2.0
	for tile_index in range(tile_count):
		var tile_width := minf(16.0, remaining_width)
		var tile := Sprite2D.new()
		var atlas := AtlasTexture.new()
		atlas.atlas = PLATFORM_TEXTURE
		atlas.region = Rect2(Vector2(0, tile_row * 16), Vector2(16, 16))
		tile.texture = atlas
		tile.position = Vector2(tile_left + tile_width / 2.0, 0)
		tile.scale.x = tile_width / 16.0
		platform.add_child(tile)

		var dirt_face := Sprite2D.new()
		var dirt_atlas := AtlasTexture.new()
		dirt_atlas.atlas = WORLD_TEXTURE
		dirt_atlas.region = Rect2(Vector2(tile_column * 16, 16), Vector2(16, 16))
		dirt_face.texture = dirt_atlas
		dirt_face.position = Vector2(tile_left + tile_width / 2.0, height / 2.0 + 13.0)
		dirt_face.scale.x = tile_width / 16.0
		platform.add_child(dirt_face)

		tile_left += tile_width
		remaining_width -= tile_width
	if moving:
		var arrow := Polygon2D.new()
		arrow.polygon = PackedVector2Array([
			Vector2(-5, -12), Vector2(0, -16), Vector2(5, -12)
		])
		arrow.color = Color("#fff6a6")
		platform.add_child(arrow)
	world.add_child(platform)
	return platform

func _create_coin(coin_position: Vector2) -> void:
	var coin_area := Area2D.new()
	coin_area.position = coin_position
	coin_area.collision_layer = 1
	coin_area.collision_mask = 1

	var coin_shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 8.0
	coin_shape.shape = circle
	coin_area.add_child(coin_shape)

	var coin_frames := SpriteFrames.new()
	coin_frames.add_animation("spin")
	coin_frames.set_animation_loop("spin", true)
	coin_frames.set_animation_speed("spin", 12.0)
	for frame_index in range(12):
		var frame_texture := AtlasTexture.new()
		frame_texture.atlas = preload("res://assets/sprites/coin.png")
		frame_texture.region = Rect2(Vector2(frame_index * 16, 0), Vector2(16, 16))
		coin_frames.add_frame("spin", frame_texture)
	var coin_sprite := AnimatedSprite2D.new()
	coin_sprite.sprite_frames = coin_frames
	coin_sprite.animation = "spin"
	coin_sprite.play()
	coin_area.add_child(coin_sprite)

	coin_area.body_entered.connect(_on_coin_collected.bind(coin_area))
	world.add_child(coin_area)

func _on_coin_collected(body: Node2D, coin_area: Area2D) -> void:
	if body != player:
		return
	if not is_instance_valid(coin_area):
		return
	coin_area.queue_free()
	_play_sfx(COIN_SOUND)
	collected_coins_this_level += 1
	_update_coin_status()

func _update_coin_status() -> void:
	if LEVELS[current_level_index].get("boss", false):
		status_label.text = "Coins: %d / %d   Stomp the boss!" % [
			collected_coins_this_level,
			total_coins_this_level
		]
	else:
		status_label.text = "Coins: %d / %d   Reach the flag!" % [
			collected_coins_this_level,
			total_coins_this_level
		]

func _on_goal_reached(body: Node2D) -> void:
	if body != player or level_transitioning or game_won:
		return
	if goal_area == null:
		return
	goal_area.set_deferred("monitoring", false)
	level_transitioning = true
	_play_sfx(POWER_UP_SOUND)
	if current_level_index < LEVELS.size() - 1:
		status_label.text = "World clear! The snack quest continues..."
		var transition_generation := level_generation
		await get_tree().create_timer(1.0).timeout
		if level_generation != transition_generation:
			return
		load_level(current_level_index + 1)
	else:
		game_won = true
		status_label.text = "YOU BEAT THE GAME! Press R to celebrate again."

func _on_player_died() -> void:
	if game_won or level_transitioning:
		return
	_play_sfx(HURT_SOUND)
	level_transitioning = true
	status_label.text = "You fell! Restarting level..."
	var transition_generation := level_generation
	await get_tree().create_timer(0.6).timeout
	if level_generation != transition_generation:
		return
	load_level(current_level_index)

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if not game_started and (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER):
		_start_game()
	elif event.keycode == KEY_R and game_started:
		load_level(0 if game_won else current_level_index)
