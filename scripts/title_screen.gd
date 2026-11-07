extends Control

signal start_pressed

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$Center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$Center/Card/Buttons/StartButton.pressed.connect(_on_start_pressed)
	$Center/Card/Buttons/ExitButton.pressed.connect(_on_exit_pressed)

func set_victory() -> void:
	$Center/Card/Buttons/Title.text = "THE SNACK REALM\nIS SAVED!"
	$Center/Card/Buttons/Subtitle.text = "The Big Slime has joined your fan club."
	$Center/Card/Buttons/StartButton.text = "PLAY AGAIN"

func _on_start_pressed() -> void:
	start_pressed.emit()

func _on_exit_pressed() -> void:
	get_tree().quit()
