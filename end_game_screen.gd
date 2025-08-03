class_name GameOverScreen
extends PanelContainer

var text: String = "GAME OVER"

func _ready() -> void:
	%Label.text = text
	var button: Button = %Button
	button.pressed.connect(change_scene.bind("res://scenes/main_menu.tscn"))
	%PlayAgain.pressed.connect(change_scene.bind("res://scenes/map.tscn"))

func game_over(winner: int, score: int) -> void:
	visible = true
	%Message.text = "Player %d won with %d mushrooms" % [winner+1, score]
	
func draw() -> void:
	visible = true
	%Message.text = "Game ended in a draw"

func change_scene(file: String):
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file(file)
