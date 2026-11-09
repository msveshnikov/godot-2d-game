@tool
extends Node2D
## Builds a whole level from an ASCII map (one character = one 16px tile).
## Edit the `map` text in the Inspector; the level redraws live in the editor.
##
## TERRAIN (solid; top row of a block gets the "top" tile automatically)
##   G grass   B dirt-brick   S sand   T stone   C candy   P pink-brick
##   I slate-ice   W snow   D dark-brick   H crate
## ONE-WAY (jump up through them)
##   s sand ledge   = rope bridge (brown)   - rope bridge (beige)   _ rope bridge (red)
## LIQUIDS (deadly!)   w water   g goo   l lava   i icy water
## INTERACTIVE
##   ? coin block   ! surprise block   c crumbly ice   ^ bounce mushroom   * sugar fruit
## ENTITIES
##   @ player start   $ coin   F goal flag   1 green slime   2 purple slime   X boss
##   M / N moving platform (sideways, short / long)   V / U moving platform (up-down, short / long)
##   & sign (texts taken in order from `sign_texts`)
## DECOR (no collision)
##   t tree   o orange tree   e teal tree   p palm   b bush   y round bush   m mini mushroom
##   k bottle   u pumpkin   j log   f fence   n signpost

const TILE := 16
const ATLAS := preload("res://assets/sprites/world_tileset.png")
const PLATFORM_TEX := preload("res://assets/sprites/platforms.png")
const FRUIT_TEX := preload("res://assets/sprites/fruit.png")
const COIN_SCENE := preload("res://scenes/objects/coin.tscn")
const SLIME_SCENE := preload("res://scenes/objects/slime.tscn")
const MOVING_SCENE := preload("res://scenes/objects/moving_platform.tscn")
const GOAL_SCENE := preload("res://scenes/objects/goal.tscn")
const SIGN_SCENE := preload("res://scenes/objects/sign.tscn")
const BOSS_SCENE := preload("res://scenes/objects/boss.tscn")
const MysteryBlock := preload("res://scripts/mystery_block.gd")
const BounceMushroom := preload("res://scripts/bounce_mushroom.gd")
const CrumbleBlock := preload("res://scripts/crumble_block.gd")
const Fruit := preload("res://scripts/fruit.gd")
const LiquidHazard := preload("res://scripts/liquid_hazard.gd")

const TERRAIN := {
	"G": [Vector2i(0, 0), Vector2i(0, 1)],
	"B": [Vector2i(1, 0), Vector2i(1, 1)],
	"S": [Vector2i(2, 0), Vector2i(2, 1)],
	"T": [Vector2i(3, 0), Vector2i(3, 1)],
	"C": [Vector2i(4, 0), Vector2i(4, 1)],
	"P": [Vector2i(5, 0), Vector2i(5, 1)],
	"I": [Vector2i(6, 0), Vector2i(6, 1)],
	"W": [Vector2i(7, 0), Vector2i(7, 1)],
	"D": [Vector2i(8, 0), Vector2i(8, 1)],
	"H": [Vector2i(7, 3), Vector2i(7, 4)],
}
const BRIDGE_ROW := {"=": 0, "-": 1, "_": 2}
# [surface, fill, shallow puddle]
const LIQUID := {
	"w": [Vector2i(4, 9), Vector2i(4, 10), Vector2i(5, 9)],
	"g": [Vector2i(4, 11), Vector2i(4, 12), Vector2i(5, 11)],
	"l": [Vector2i(4, 13), Vector2i(4, 14), Vector2i(5, 13)],
	"i": [Vector2i(6, 9), Vector2i(6, 10), Vector2i(7, 9)],
}
const LIQUID_DEATH := {
	"w": "GLUB GLUB! KNIGHTS SINK!",
	"g": "STUCK IN THE GOO!",
	"l": "TOO SPICY!",
	"i": "BRAIN FREEZE!",
}
const DECOR := {
	"t": [Rect2(0, 48, 16, 48)],
	"o": [Rect2(80, 48, 16, 48)],
	"e": [Rect2(96, 48, 16, 48)],
	"p": [Rect2(32, 80, 48, 64)],
	"b": [Rect2(16, 48, 16, 16), Rect2(16, 64, 16, 16), Rect2(16, 80, 16, 16), Rect2(16, 96, 16, 16)],
	"y": [Rect2(80, 96, 16, 16), Rect2(96, 96, 16, 16), Rect2(80, 112, 16, 16), Rect2(96, 112, 16, 16), Rect2(80, 128, 16, 16), Rect2(96, 128, 16, 16)],
	"m": [Rect2(128, 80, 16, 16), Rect2(128, 96, 16, 16), Rect2(128, 112, 16, 16), Rect2(128, 128, 16, 16)],
	"k": [Rect2(0, 112, 16, 16), Rect2(16, 112, 16, 16), Rect2(0, 128, 16, 16), Rect2(16, 128, 16, 16)],
	"u": [Rect2(64, 128, 16, 16)],
	"j": [Rect2(32, 128, 16, 16)],
	"f": [Rect2(144, 48, 16, 16), Rect2(144, 64, 16, 16)],
	"n": [Rect2(128, 48, 16, 16), Rect2(128, 64, 16, 16)],
}
const CLOUD_POLY := [Vector2(-42, 4), Vector2(-38, -7), Vector2(-29, -8), Vector2(-24, -18), Vector2(-12, -20), Vector2(-3, -13), Vector2(8, -16), Vector2(18, -10), Vector2(21, -3), Vector2(34, -3), Vector2(40, 4), Vector2(36, 11), Vector2(-37, 12)]

@export_multiline var map := "":
	set(value):
		map = value
		_queue_rebuild()
@export_enum("Brown", "Beige", "Pink", "Slate") var block_style := 0:
	set(value):
		block_style = value
		_queue_rebuild()
@export_enum("Green", "Brown", "Yellow", "Cyan") var platform_style := 0:
	set(value):
		platform_style = value
		_queue_rebuild()
@export var sign_texts: PackedStringArray = []:
	set(value):
		sign_texts = value
		_queue_rebuild()

@export_group("Backdrop walls")
## Cave / jelly walls painted behind the level, in tile coordinates.
@export var backdrops: Array[Rect2i] = []:
	set(value):
		backdrops = value
		_queue_rebuild()
## Colour family per backdrop rect: 0 blue, 1 peach, 2 berry, 3 grey.
@export var backdrop_colors: PackedInt32Array = []:
	set(value):
		backdrop_colors = value
		_queue_rebuild()
@export var backdrop_tint := Color(0.62, 0.62, 0.75, 1):
	set(value):
		backdrop_tint = value
		_queue_rebuild()

@export_group("Sky")
@export var sky_top := Color(0.36, 0.74, 1, 1):
	set(value):
		sky_top = value
		_queue_rebuild()
@export var sky_bottom := Color(0.78, 0.95, 1, 1):
	set(value):
		sky_bottom = value
		_queue_rebuild()
@export var far_hills := Color(0.68, 0.91, 0.78, 1):
	set(value):
		far_hills = value
		_queue_rebuild()
@export var near_hills := Color(0.29, 0.72, 0.48, 1):
	set(value):
		near_hills = value
		_queue_rebuild()
@export var cloud_color := Color(1, 0.98, 0.9, 0.85):
	set(value):
		cloud_color = value
		_queue_rebuild()
@export var stars := false:
	set(value):
		stars = value
		_queue_rebuild()

var size_tiles := Vector2i.ZERO
var player_start := Vector2(32, 32)
var bonus_coins := 0
var goal: Node2D
var boss: Node2D

var _grid: Array[String] = []
var _generated: Node2D
var _parallax_layers: Array = []
var _rebuild_queued := false
var _sky_layer: CanvasLayer

func _ready() -> void:
	_rebuild()

func _queue_rebuild() -> void:
	if not is_inside_tree() or _rebuild_queued:
		return
	_rebuild_queued = true
	_rebuild.call_deferred()

func world_size() -> Vector2:
	return Vector2(size_tiles * TILE)

func _rebuild() -> void:
	_rebuild_queued = false
	if is_instance_valid(_generated):
		remove_child(_generated)
		_generated.queue_free()
	if is_instance_valid(_sky_layer):
		_sky_layer.queue_free()
	_parallax_layers.clear()
	bonus_coins = 0
	goal = null
	boss = null
	_generated = Node2D.new()
	_generated.name = "Generated"
	add_child(_generated)

	_grid.clear()
	var width := 0
	for line in map.split("\n"):
		var clean := line.replace("\r", "")
		_grid.append(clean)
		width = maxi(width, clean.length())
	size_tiles = Vector2i(width, _grid.size())

	_build_sky()
	_build_backdrop_walls()
	_build_tiles()
	_build_objects()

# ---------------------------------------------------------------- helpers

func _at(x: int, y: int) -> String:
	if y < 0 or y >= _grid.size() or x < 0 or x >= _grid[y].length():
		return " "
	return _grid[y][x]

func _is_solid(ch: String) -> bool:
	return TERRAIN.has(ch) or ch in ["?", "!", "c", "^"]

func _cell_center(x: int, y: int) -> Vector2:
	return Vector2(x * TILE + TILE * 0.5, y * TILE + TILE * 0.5)

func _cell_bottom(x: int, y: int) -> Vector2:
	return Vector2(x * TILE + TILE * 0.5, (y + 1) * TILE)

func _region(r: Rect2) -> AtlasTexture:
	var tex := AtlasTexture.new()
	tex.atlas = ATLAS
	tex.region = r
	return tex

func _hash(x: int, y: int) -> int:
	return absi(x * 73856093 ^ y * 19349663)

# ---------------------------------------------------------------- tiles

func _make_tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 1)
	var src := TileSetAtlasSource.new()
	src.texture = ATLAS
	src.texture_region_size = Vector2i(TILE, TILE)
	ts.add_source(src, 0)
	var full := PackedVector2Array([Vector2(-8, -8), Vector2(8, -8), Vector2(8, 8), Vector2(-8, 8)])
	var ledge := PackedVector2Array([Vector2(-8, -8), Vector2(8, -8), Vector2(8, -3), Vector2(-8, -3)])
	for pair in TERRAIN.values():
		for coords in pair:
			if not src.has_tile(coords):
				src.create_tile(coords)
				var td := src.get_tile_data(coords, 0)
				td.add_collision_polygon(0)
				td.set_collision_polygon_points(0, 0, full)
	var one_way: Array[Vector2i] = [Vector2i(2, 2)]
	for row in 3:
		for col in 3:
			one_way.append(Vector2i(9 + col, row))
	for coords in one_way:
		src.create_tile(coords)
		var td := src.get_tile_data(coords, 0)
		td.add_collision_polygon(0)
		td.set_collision_polygon_points(0, 0, ledge)
		td.set_collision_polygon_one_way(0, 0, true)
	for trio in LIQUID.values():
		for coords in trio:
			if not src.has_tile(coords):
				src.create_tile(coords)
	for col in 4:
		for row in range(9, 16):
			var coords := Vector2i(col, row)
			if not src.has_tile(coords):
				src.create_tile(coords)
	return ts

func _build_backdrop_walls() -> void:
	if backdrops.is_empty():
		return
	var layer := TileMapLayer.new()
	layer.name = "BackdropWalls"
	layer.tile_set = _make_tileset()
	layer.collision_enabled = false
	layer.modulate = backdrop_tint
	layer.z_index = -5
	_generated.add_child(layer)
	# each family darkens as it goes down, with bubbly seams between bands
	var ramp := [11, 11, 11, 12, 13, 13, 13, 14, 15]
	for i in backdrops.size():
		var r: Rect2i = backdrops[i]
		var col := backdrop_colors[i] if i < backdrop_colors.size() else i % 4
		for y in range(r.position.y, r.end.y):
			var depth := y - r.position.y
			var row: int = ramp[depth % ramp.size()]  # repeating strata
			if depth == 0:
				row = 10
			for x in range(r.position.x, r.end.x):
				layer.set_cell(Vector2i(x, y), 0, Vector2i(col, row))

func _build_tiles() -> void:
	var layer := TileMapLayer.new()
	layer.name = "Tiles"
	layer.tile_set = _make_tileset()
	_generated.add_child(layer)
	var liquid_layer := TileMapLayer.new()
	liquid_layer.name = "Liquids"
	liquid_layer.tile_set = layer.tile_set
	liquid_layer.collision_enabled = false
	liquid_layer.z_index = 3
	liquid_layer.modulate = Color(1, 1, 1, 0.92)
	_generated.add_child(liquid_layer)

	for y in size_tiles.y:
		var run_start := -1
		var run_kind := ""
		for x in size_tiles.x + 1:
			var ch := _at(x, y)
			if TERRAIN.has(ch):
				var pair: Array = TERRAIN[ch]
				var top := _at(x, y - 1) != ch
				layer.set_cell(Vector2i(x, y), 0, pair[0] if top else pair[1])
			elif ch == "s":
				layer.set_cell(Vector2i(x, y), 0, Vector2i(2, 2))
			elif BRIDGE_ROW.has(ch):
				layer.set_cell(Vector2i(x, y), 0, Vector2i(9 + x % 3, BRIDGE_ROW[ch]))
			elif LIQUID.has(ch):
				var trio: Array = LIQUID[ch]
				var surface := not LIQUID.has(_at(x, y - 1))
				var shallow := surface and not LIQUID.has(_at(x, y + 1))
				liquid_layer.set_cell(Vector2i(x, y), 0, trio[2] if shallow else (trio[0] if surface else trio[1]))
			# hazard areas: merge each run of surface liquid on a row
			var is_surface := LIQUID.has(ch) and not LIQUID.has(_at(x, y - 1))
			if is_surface and run_start < 0:
				run_start = x
				run_kind = ch
			elif run_start >= 0 and (not is_surface or ch != run_kind):
				_add_liquid_hazard(run_start, x - 1, y, run_kind)
				run_start = x if is_surface else -1
				run_kind = ch

func _add_liquid_hazard(x0: int, x1: int, y: int, kind: String) -> void:
	var shallow := not LIQUID.has(_at(x0, y + 1))
	var hazard := LiquidHazard.new()
	hazard.death_reason = LIQUID_DEATH[kind]
	var top := 12.0 if shallow else 6.0
	hazard.setup(Rect2(x0 * TILE + 2, y * TILE + top, (x1 - x0 + 1) * TILE - 4, TILE - top + 40))
	_generated.add_child(hazard)

# ---------------------------------------------------------------- objects

func _build_objects() -> void:
	var sign_index := 0
	var surprise_index := 0
	var mushroom_index := 0
	var fruit_index := 0
	var decor := Node2D.new()
	decor.name = "Decor"
	decor.z_index = -2
	_generated.add_child(decor)
	for y in size_tiles.y:
		for x in size_tiles.x:
			var ch := _at(x, y)
			match ch:
				"@":
					player_start = _cell_bottom(x, y)
					if Engine.is_editor_hint():
						var marker := Sprite2D.new()
						marker.texture = preload("res://assets/sprites/knight.png")
						marker.region_enabled = true
						marker.region_rect = Rect2(0, 0, 32, 32)
						marker.position = player_start + Vector2(0, -12)
						_generated.add_child(marker)
				"$":
					var coin := COIN_SCENE.instantiate()
					coin.position = _cell_center(x, y)
					_generated.add_child(coin)
				"F":
					goal = GOAL_SCENE.instantiate()
					goal.name = "Goal"
					goal.position = _cell_bottom(x, y) + Vector2(0, -22)
					_generated.add_child(goal)
				"X":
					boss = BOSS_SCENE.instantiate()
					boss.name = "Boss"
					boss.position = _cell_bottom(x, y) + Vector2(0, -36)
					_generated.add_child(boss)
				"1", "2":
					_spawn_slime(x, y, ch == "2")
				"M", "N", "V", "U":
					_spawn_mover(x, y, ch)
				"&":
					var sign_node := SIGN_SCENE.instantiate()
					sign_node.position = _cell_bottom(x, y)
					if sign_index < sign_texts.size():
						sign_node.sign_text = sign_texts[sign_index]
					sign_index += 1
					decor.add_child(sign_node)
				"?", "!":
					var block := MysteryBlock.new()
					block.style = block_style
					block.surprise = ch == "!"
					block.contents = 0 if ch == "?" else surprise_index % 3
					if ch == "!":
						surprise_index += 1
					bonus_coins += block.coin_value()
					block.position = _cell_center(x, y)
					_generated.add_child(block)
				"c":
					var ice := CrumbleBlock.new()
					ice.position = _cell_center(x, y)
					_generated.add_child(ice)
				"^":
					var shroom := BounceMushroom.new()
					shroom.variant = mushroom_index % 4
					mushroom_index += 1
					shroom.position = _cell_center(x, y)
					_generated.add_child(shroom)
				"*":
					var fruit := Fruit.new()
					fruit.frame_index = (fruit_index * 5) % 16
					fruit_index += 1
					fruit.position = _cell_center(x, y)
					_generated.add_child(fruit)
				_:
					if DECOR.has(ch):
						var options: Array = DECOR[ch]
						var region: Rect2 = options[_hash(x, y) % options.size()]
						var sprite := Sprite2D.new()
						sprite.texture = _region(region)
						sprite.centered = false
						sprite.position = _cell_bottom(x, y) - Vector2(region.size.x * 0.5, region.size.y)
						sprite.flip_h = _hash(y, x) % 2 == 0 and ch in ["t", "o", "e", "b", "y", "p"]
						decor.add_child(sprite)

func _spawn_slime(x: int, y: int, purple: bool) -> void:
	# patrol the walkable floor this slime is standing on (max 5 tiles each way)
	var left := x
	var right := x
	while left > x - 5 and not _is_solid(_at(left - 1, y)) and _supports(left - 1, y + 1):
		left -= 1
	while right < x + 5 and not _is_solid(_at(right + 1, y)) and _supports(right + 1, y + 1):
		right += 1
	var slime := SLIME_SCENE.instantiate()
	slime.purple = purple
	slime.position = Vector2((left + right + 1) * TILE * 0.5, (y + 1) * TILE - 4)
	slime.patrol_distance = maxf(0.0, (right - left + 1) * TILE * 0.5 - 10.0)
	slime.move_speed = 44.0 if purple else 34.0
	_generated.add_child(slime)

func _supports(x: int, y: int) -> bool:
	var ch := _at(x, y)
	return _is_solid(ch) or ch == "s" or BRIDGE_ROW.has(ch)

func _spawn_mover(x: int, y: int, ch: String) -> void:
	var mover := MOVING_SCENE.instantiate()
	mover.position = _cell_center(x, y) + Vector2(0, 1)
	match ch:
		"M": mover.travel = Vector2(40, 0)
		"N": mover.travel = Vector2(80, 0)
		"V": mover.travel = Vector2(0, 40)
		"U": mover.travel = Vector2(0, 80)
	mover.cycles_per_second = 0.32 if ch in ["M", "V"] else 0.2
	mover.cycles_per_second += float(_hash(x, y) % 7) * 0.012
	var tex := AtlasTexture.new()
	tex.atlas = PLATFORM_TEX
	tex.region = Rect2(0, platform_style * 16, 64, 16)
	_generated.add_child(mover)
	mover.get_node("Visual").texture = tex
	if ch in ["M", "N"]:
		mover.get_node("DirectionArrow").rotation = PI * 0.5

# ---------------------------------------------------------------- background

func _build_sky() -> void:
	var w := float(size_tiles.x * TILE)
	var h := float(size_tiles.y * TILE)
	# sky gradient lives on its own canvas layer, glued to the screen
	if not Engine.is_editor_hint():
		_sky_layer = CanvasLayer.new()
		_sky_layer.layer = -10
		var rect := TextureRect.new()
		var grad := Gradient.new()
		grad.set_color(0, sky_top)
		grad.set_color(1, sky_bottom)
		var tex := GradientTexture2D.new()
		tex.gradient = grad
		tex.fill_from = Vector2(0, 0)
		tex.fill_to = Vector2(0, 1)
		rect.texture = tex
		rect.stretch_mode = TextureRect.STRETCH_SCALE
		rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		_sky_layer.add_child(rect)
		add_child(_sky_layer)
	else:
		var sky := Polygon2D.new()
		sky.polygon = PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w, h), Vector2(0, h)])
		sky.vertex_colors = PackedColorArray([sky_top, sky_top, sky_bottom, sky_bottom])
		sky.z_index = -30
		_generated.add_child(sky)
		return  # parallax layers only make sense with a live camera

	var rng := RandomNumberGenerator.new()
	rng.seed = size_tiles.x * 31 + size_tiles.y
	if stars:
		var star_layer := _parallax(Vector2(0.05, 0.05), -29)
		for i in 140:
			var star := Polygon2D.new()
			var s := rng.randf_range(0.6, 1.6)
			star.polygon = PackedVector2Array([Vector2(0, -s * 2), Vector2(s * 0.6, 0), Vector2(0, s * 2), Vector2(-s * 0.6, 0)])
			star.color = Color(1, 0.97, 0.8, rng.randf_range(0.4, 1.0))
			star.position = Vector2(rng.randf_range(-100, w * 0.3 + 800), rng.randf_range(-300, h * 0.3 + 300))
			star_layer.add_child(star)
	var clouds := _parallax(Vector2(0.15, 0.25), -28)
	for i in int(w / 220.0) + 4:
		var cloud := Polygon2D.new()
		cloud.polygon = PackedVector2Array(CLOUD_POLY)
		cloud.color = cloud_color
		var s := rng.randf_range(0.6, 1.4)
		cloud.scale = Vector2(s, s)
		cloud.position = Vector2(i * 120 + rng.randf_range(-40, 40), rng.randf_range(-40, h * 0.25 + 60))
		clouds.add_child(cloud)
	_add_hills(_parallax(Vector2(0.3, 0.45), -26), far_hills, w, h, 0.3, 0.45, rng, 70.0, 150.0)
	_add_hills(_parallax(Vector2(0.55, 0.7), -24), near_hills, w, h, 0.55, 0.7, rng, 40.0, 110.0)

func _parallax(factor: Vector2, z: int) -> Node2D:
	var layer := Node2D.new()
	layer.z_index = z
	layer.set_meta("factor", factor)
	_generated.add_child(layer)
	_parallax_layers.append(layer)
	return layer

func _add_hills(layer: Node2D, color: Color, w: float, h: float, fx: float, fy: float, rng: RandomNumberGenerator, low: float, high: float) -> void:
	# local coords: a point P is seen at P - factor * camera (relative to the camera)
	# so hills line up with the bottom of the map when the camera is near the ground
	var base_y := (h - 140.0) * fy + 70.0
	var points := PackedVector2Array()
	var x := -500.0
	var right := w * fx + 900.0
	while x < right:
		points.append(Vector2(x, base_y - rng.randf_range(low, high)))
		x += rng.randf_range(90, 170)
		points.append(Vector2(x, base_y - rng.randf_range(0, low * 0.5)))
		x += rng.randf_range(90, 170)
	points.append(Vector2(right, base_y + 2000))
	points.append(Vector2(-500, base_y + 2000))
	var poly := Polygon2D.new()
	poly.polygon = points
	poly.color = color
	layer.add_child(poly)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint() or _parallax_layers.is_empty():
		return
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return
	var center := cam.get_screen_center_position()
	for layer in _parallax_layers:
		var factor: Vector2 = layer.get_meta("factor")
		layer.position = center * (Vector2.ONE - factor)
