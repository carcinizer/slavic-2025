extends CanvasLayer

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		visible = not visible


func _on_continue_pressed() -> void:
	visible = false

func _on_quit_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_quit_to_desktop_pressed() -> void:
	get_tree().quit()
