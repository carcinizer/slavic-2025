extends Control

@export var settings_menu_scene: PackedScene
@export var hide_when_displaying_settings: Node


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/map.tscn")


func _on_settings_button_pressed() -> void:
	## Instantiate settings scene and add to the tree
	var settings_menu_instance: SettingsMenu = \
	settings_menu_scene.instantiate() as SettingsMenu
	add_child(settings_menu_instance)
	## Hide the main menu
	hide_when_displaying_settings.hide()
	## Make the main menu appear again when the settings menu is closed
	settings_menu_instance.settings_menu_closed.connect(
		hide_when_displaying_settings.show
		)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
