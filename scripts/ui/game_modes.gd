extends Control

const Types = preload("res://scripts/skee/skee_types.gd")


func _ready() -> void:
	theme = ThemeFactory.make()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.05, 0.035, 0.03)
	add_child(bg)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.custom_minimum_size = Vector2(540, 520)
	box.offset_left = -270
	box.offset_right = 270
	box.offset_top = -260
	box.offset_bottom = 260
	add_child(box)
	var t := Label.new()
	t.text = "Game Modes"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 28)
	box.add_child(t)
	box.add_child(_m("CLASSIC", "Nine balls. Add them up.", Types.Mode.CLASSIC))
	box.add_child(_m("HIGH SCORE", "Streaks of 30+ multiply.", Types.Mode.HIGH_SCORE))
	box.add_child(_m("TIMED", "Sixty seconds. Keep rolling.", Types.Mode.TIMED))
	box.add_child(_m("PRECISION", "Hit the called ring.", Types.Mode.PRECISION))
	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size.y = 44
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn"))
	box.add_child(back)


func _m(title: String, blurb: String, mode) -> Button:
	var b := Button.new()
	b.text = "%s\n%s" % [title, blurb]
	b.custom_minimum_size.y = 68
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.pressed.connect(func():
		AudioManager.play("ui")
		GameSession.reset_defaults()
		GameSession.mode = mode
		get_tree().change_scene_to_file("res://scenes/main/game.tscn")
	)
	return b
