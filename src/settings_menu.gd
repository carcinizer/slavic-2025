class_name SettingsMenu
extends Control

signal settings_menu_closed


func _on_back_button_pressed() -> void:
	settings_menu_closed.emit()
	queue_free()


func _on_add_player_button_pressed() -> void:
	pass
