extends Node2D

signal completed
signal failed
signal boss_beaten

const ENEMY_DEATH_SOUND := preload("res://assets/sounds/explosion.wav")
const PLAYER_HURT_SOUND := preload("res://assets/sounds/hurt.wav")
const COIN_COLLECT_SOUND := preload("res://assets/sounds/coin.wav")
const POWER_UP_SOUND := preload("res://assets/sounds/power_up.wav")
const TAP_SOUND := preload("res://assets/sounds/tap.wav")
const JUMP_SOUND := preload("res://assets/sounds/jump.wav")
const POP_FONT := preload("res://assets/fonts/PixelOperator8-Bold.ttf")
const STOMP_JOKES := ["SPLAT!", "SQUISH!", "FLOOR JAM!", "BYE SLIME", "POP!", "JELLY'D"]

@export var level_title := "World"
@export var intro_text := "Find coins and reach the flag!"

@onready var player: CharacterBody2D = $Player
@onready var map: Node2D = $Map
@onready var status_label: Label = $HUD/Panel/StatusLabel
@onready var title_label: Label = $HUD/Panel/TitleLabel
@onready var boss_health: ProgressBar = $HUD/BossHealth
@onready var death_notice: Panel = $HUD/DeathNotice
@onready var death_label: Label = $HUD/DeathNotice/DeathLabel

var sounds := {}
var coins_collected := 0
var coin_total := 0
var transition_pending := false
var boss_node: Area2D
var boss_hits := 0
var pop_settings: LabelSettings

func _ready() -> void:
	for key in ["enemy", "hurt", "coin", "power", "tap", "boing"]:
		var p := AudioStreamPlayer.new()
		p.stream = {"enemy": ENEMY_DEATH_SOUND, "hurt": PLAYER_HURT_SOUND, "coin": COIN_COLLECT_SOUND, "power": POWER_UP_SOUND, "tap": TAP_SOUND, "boing": JUMP_SOUND}[key]
		if key == "boing":
			p.pitch_scale = 0.6
		add_child(p)
		sounds[key] = p
	pop_settings = LabelSettings.new()
	pop_settings.font = POP_FONT
	pop_settings.font_size = 8
	pop_settings.outline_size = 3
	pop_settings.outline_color = Color(0.15, 0.08, 0.2)

	title_label.text = level_title.to_upper()
	player.global_position = map.to_global(map.player_start)
	var world: Vector2 = map.world_size()
	var cam: Camera2D = $Player/Camera2D
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = int(world.x)
	cam.limit_bottom = int(world.y)
	cam.reset_smoothing()
	cam.make_current()
	player.death_y = map.global_position.y + world.y + 24.0

	for coin in get_tree().get_nodes_in_group("coins"):
		if is_ancestor_of(coin):
			coin_total += 1
			coin.connect("collected", _on_coin_collected)
	coin_total += map.bonus_coins
	for enemy in get_tree().get_nodes_in_group("slimes"):
		if is_ancestor_of(enemy):
			_hook_slime(enemy)
	for node in get_tree().get_nodes_in_group("level_events"):
		if is_ancestor_of(node):
			_hook_events(node)
	if map.goal:
		map.goal.body_entered.connect(_on_goal_entered)
	if map.boss:
		boss_node = map.boss
		boss_node.connect("stomped", _on_boss_stomped)
		boss_node.connect("hit_player", _on_hazard_hit.bind("THE BIG SLIME SAT ON YOU!"))
		boss_health.visible = true
		boss_health.value = 4
		_update_status("Stomp the Big Slime four times!")
	else:
		_update_status(intro_text)
	player.connect("died", _on_player_died)

func _hook_slime(enemy: Node) -> void:
	enemy.connect("stomped", _on_slime_stomped.bind(enemy))
	enemy.connect("hit_player", _on_hazard_hit.bind("A SLIME HUGGED YOU!"))

func _hook_events(node: Node) -> void:
	if node.has_signal("announce"):
		node.connect("announce", _on_announce.bind(node))
	if node.has_signal("coin_popped"):
		node.connect("coin_popped", _on_coin_collected)
	if node.has_signal("killed"):
		node.connect("killed", _on_hazard_hit)
	if node.has_signal("spawn_requested"):
		node.connect("spawn_requested", _on_spawn_requested.bind(node))

func _on_spawn_requested(thing: Node2D, source: Node) -> void:
	source.get_parent().add_child.call_deferred(thing)
	if thing.is_in_group("slimes") or thing.has_signal("stomped"):
		_hook_slime(thing)
	elif thing.has_signal("announce"):
		_hook_events.call_deferred(thing)

func _on_announce(text: String, at: Vector2, source: Node) -> void:
	if source.has_signal("eaten"):
		sounds.power.play()
		_update_status("SUGAR RUSH! Faster legs, bouncier knees!")
	elif source.has_method("coin_value"):
		sounds.tap.play()
	elif source.has_method("player_touched") and source.get("launch_speed") != null:
		sounds.boing.pitch_scale = randf_range(0.5, 0.7)
		sounds.boing.play()
	pop_text(text, at)

func pop_text(text: String, at: Vector2, color := Color(1, 0.95, 0.55)) -> void:
	var label := Label.new()
	label.text = text
	label.label_settings = pop_settings
	label.modulate = color
	label.z_index = 50
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size = Vector2(120, 12)
	label.position = to_local(at) - Vector2(60, 6)
	label.pivot_offset = Vector2(60, 6)
	label.scale = Vector2(0.3, 0.3)
	add_child(label)
	var tween := label.create_tween()
	tween.tween_property(label, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "position:y", label.position.y - 16.0, 0.6)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.6).set_delay(0.25)
	tween.tween_callback(label.queue_free)

func _on_coin_collected() -> void:
	coins_collected += 1
	sounds.coin.play()
	if coins_collected == coin_total:
		_update_status("ALL %d COINS! You are disgustingly rich." % coin_total)
		pop_text("RICH!!", player.global_position + Vector2(0, -30), Color(0.6, 1, 0.6))
	else:
		_update_status("Coins %d / %d  ·  Find the flag!" % [coins_collected, coin_total])

func _on_slime_stomped(enemy: Node2D) -> void:
	sounds.enemy.play()
	var joke: String = STOMP_JOKES[randi() % STOMP_JOKES.size()]
	if is_instance_valid(enemy):
		pop_text(joke, enemy.global_position + Vector2(0, -20), Color(0.7, 1, 0.5))
	_update_status("%s The slime is now floor jam." % joke)

func _on_hazard_hit(reason: String = "ENEMY GOT YOU!") -> void:
	if transition_pending:
		return
	sounds.hurt.play()
	_begin_level_restart(reason)

func _on_goal_entered(body: Node2D) -> void:
	if body != player or transition_pending:
		return
	transition_pending = true
	if coins_collected == coin_total:
		_update_status("PERFECT! Every coin! On to the next snack...")
	else:
		_update_status("World clear! (%d / %d coins) On to the next snack..." % [coins_collected, coin_total])
	pop_text("HOORAY!", player.global_position + Vector2(0, -34), Color(1, 0.6, 0.85))
	await get_tree().create_timer(1.0).timeout
	if is_inside_tree():
		completed.emit()

func _on_boss_stomped() -> void:
	if transition_pending:
		return
	boss_hits += 1
	boss_health.value = 4 - boss_hits
	pop_text(["OOF!", "BONK!", "OUCHIE!", "MY JELLY!"][mini(boss_hits - 1, 3)], boss_node.global_position + Vector2(0, -50), Color(1, 0.6, 0.6))
	if boss_hits >= 4:
		transition_pending = true
		sounds.enemy.play()
		_update_status("THE BIG SLIME SURRENDERS!")
		await get_tree().create_timer(0.7).timeout
		if is_inside_tree():
			boss_beaten.emit()
	else:
		sounds.tap.play()
		_update_status("BONK! %d more good head-bonks!" % (4 - boss_hits))

func _on_player_died() -> void:
	_begin_level_restart(["YOU FELL!", "WHOOPS, GRAVITY!", "BYE BYE KNIGHT!"][randi() % 3])

func _begin_level_restart(reason: String) -> void:
	if transition_pending:
		return
	transition_pending = true
	player.set_physics_process(false)
	death_label.text = "%s\nLEVEL RESTARTING..." % reason
	death_notice.show()
	_update_status("%s Restarting level..." % reason)
	await get_tree().create_timer(1.2).timeout
	if is_inside_tree():
		failed.emit()

func _update_status(message: String) -> void:
	status_label.text = message
