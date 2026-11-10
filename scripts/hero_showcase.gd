extends Node2D
## Preview of all warrior / mage animations. Run this scene on its own (F6).

const FONT := preload("res://assets/fonts/PixelOperator8.ttf")
const SCALE := 8.0
const CELL := Vector2(210, 250)
const ORIGIN := Vector2(150, 190)

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("3a4452"))
	for row in 2:
		var names: Array = HeroSprite.WARRIOR_ANIMS.keys() if row == 0 else HeroSprite.MAGE_ANIMS.keys()
		for col in names.size():
			var pos := ORIGIN + Vector2(col, row) * CELL
			var sprite := HeroSprite.new()
			sprite.hero = row as HeroSprite.Hero
			sprite.position = pos
			sprite.scale = Vector2.ONE * SCALE
			add_child(sprite)
			sprite.play(names[col])
			# replay one-shot animations after a short pause
			sprite.animation_finished.connect(_replay.bind(sprite, names[col]))

			var label := Label.new()
			label.text = names[col]
			label.add_theme_font_override("font", FONT)
			label.add_theme_font_size_override("font_size", 16)
			label.position = pos + Vector2(-60, 80)
			label.size = Vector2(120, 20)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			add_child(label)

func _replay(sprite: HeroSprite, anim_name: String) -> void:
	await get_tree().create_timer(0.6).timeout
	sprite.play(anim_name)
