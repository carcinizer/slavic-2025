extends CanvasLayer

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		visible = not visible
		get_tree().paused = not get_tree().paused


func _on_continue_pressed() -> void:
	visible = false
	get_tree().paused = false

func _on_quit_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_quit_to_desktop_pressed() -> void:
	get_tree().quit()


func _on_toggle_full_screen_pressed() -> void:
	GLOB.settings.fullscreen = not GLOB.settings.fullscreen

# Unpause on quit to menu and other unexpected events
func _exit_tree() -> void:
	get_tree().paused = false
