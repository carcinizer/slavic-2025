class_name GameOverScreen
extends PanelContainer

var text: String = "GAME OVER"

func _ready() -> void:
	%Label.text = text
	var button: Button = %Button
	button.pressed.connect(get_tree().change_scene_to_file.bind("res://scenes/main_menu.tscn"))
	button.pressed.connect(queue_free)
