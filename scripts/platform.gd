extends StaticBody2D

const TILE_ATLAS := preload("res://assets/sprites/world_tileset.png")
@export_range(0, 8) var tile_column := 0

func _ready() -> void:
	for index in range(8):
		var top := AtlasTexture.new()
		top.atlas = TILE_ATLAS
		top.region = Rect2(tile_column * 16, 16, 16, 16)
		$TopTiles.get_child(index).texture = top
