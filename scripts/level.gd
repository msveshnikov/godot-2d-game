extends Node2D

signal completed
signal failed
signal boss_beaten

@export var level_title := "World"
@export var world_width := 1200

@onready var player: CharacterBody2D = $Player
@onready var status_label: Label = $HUD/Panel/StatusLabel
@onready var title_label: Label = $HUD/Panel/TitleLabel
@onready var boss_health: ProgressBar = $HUD/BossHealth

var coins_collected := 0
var coin_total := 0
var transition_pending := false
var boss_node: Area2D
var boss_hits := 0

func _ready() -> void:
	title_label.text = level_title.to_upper()
	$Player/Camera2D.limit_right = world_width
	$Player/Camera2D.make_current()
	for coin in get_tree().get_nodes_in_group("coins"):
		if coin.get_parent() == self or is_ancestor_of(coin):
			coin_total += 1
			coin.connect("collected", _on_coin_collected)
	for enemy in get_tree().get_nodes_in_group("slimes"):
		if is_ancestor_of(enemy):
			enemy.connect("stomped", _on_slime_stomped)
			enemy.connect("hit_player", _on_hazard_hit)
	if has_node("Goal"):
		$Goal.body_entered.connect(_on_goal_entered)
	if has_node("Boss"):
		boss_node = $Boss
		boss_node.connect("stomped", _on_boss_stomped)
		boss_node.connect("hit_player", _on_hazard_hit)
		boss_health.visible = true
		boss_health.value = 4
		_update_status("Stomp the Big Slime four times!")
	else:
		_update_status("Find coins and reach the flag!")
	player.connect("died", _on_player_died)

func _on_coin_collected() -> void:
	coins_collected += 1
	_update_status("Coins %d / %d  ·  Find the flag!" % [coins_collected, coin_total])

func _on_slime_stomped() -> void:
	_update_status("SPLAT! The slime is now floor jam.")

func _on_hazard_hit() -> void:
	_on_player_died()

func _on_goal_entered(body: Node2D) -> void:
	if body != player or transition_pending:
		return
	transition_pending = true
	_update_status("World clear! On to the next snack...")
	await get_tree().create_timer(0.8).timeout
	if is_inside_tree():
		completed.emit()

func _on_boss_stomped() -> void:
	if transition_pending:
		return
	boss_hits += 1
	boss_health.value = 4 - boss_hits
	if boss_hits >= 4:
		transition_pending = true
		_update_status("THE BIG SLIME SURRENDERS!")
		await get_tree().create_timer(0.7).timeout
		if is_inside_tree():
			boss_beaten.emit()
	else:
		_update_status("BONK! %d more good head-bonks!" % (4 - boss_hits))

func _on_player_died() -> void:
	if transition_pending:
		return
	transition_pending = true
	_update_status("Oops! Try that bit again...")
	await get_tree().create_timer(0.55).timeout
	if is_inside_tree():
		failed.emit()

func _update_status(message: String) -> void:
	status_label.text = message
