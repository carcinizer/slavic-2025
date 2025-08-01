class_name SettingsMenu
extends Control

signal settings_menu_closed

## Array containing settings for every player
var player_profiles: Array

func _on_back_button_pressed() -> void:
	settings_menu_closed.emit()
	queue_free()
