class_name HeroSprite
extends AnimatedSprite2D
## 16x16 warrior / mage sprite built from the strips in assets/sprites/heroes.
## Animations: idle, walk, hurt, death, plus "attack" (warrior) or "cast" (mage).
## Sprites face right; set flip_h to face left.

enum Hero { WARRIOR, MAGE }

const FRAME := 16
const DIR := "res://assets/sprites/heroes/"
# name: [fps, loop]
const WARRIOR_ANIMS := {
	"idle": [4.5, true],
	"walk": [8.5, true],
	"attack": [12.5, false],
	"hurt": [11.0, false],
	"death": [6.0, false],
}
const MAGE_ANIMS := {
	"idle": [4.5, true],
	"walk": [7.5, true],
	"cast": [10.0, false],
	"hurt": [11.0, false],
	"death": [6.0, false],
}

@export var hero: Hero = Hero.WARRIOR:
	set(value):
		hero = value
		if is_inside_tree():
			_rebuild()

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_rebuild()

## Name of the hero's special animation: "attack" or "cast".
func action_name() -> String:
	return "attack" if hero == Hero.WARRIOR else "cast"

func _rebuild() -> void:
	var prefix := "warrior_" if hero == Hero.WARRIOR else "mage_"
	var anims: Dictionary = WARRIOR_ANIMS if hero == Hero.WARRIOR else MAGE_ANIMS
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for anim_name: String in anims:
		var strip: Texture2D = load(DIR + prefix + anim_name + ".png")
		frames.add_animation(anim_name)
		frames.set_animation_speed(anim_name, anims[anim_name][0])
		frames.set_animation_loop(anim_name, anims[anim_name][1])
		for i in strip.get_width() / FRAME:
			var tex := AtlasTexture.new()
			tex.atlas = strip
			tex.region = Rect2(i * FRAME, 0, FRAME, FRAME)
			frames.add_frame(anim_name, tex)
	sprite_frames = frames
	play("idle")
