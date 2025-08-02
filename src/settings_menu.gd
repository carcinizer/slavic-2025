class_name SettingsMenu
extends Control

signal settings_menu_closed
signal action_pressed(event)

var player_controls_scene = preload("res://scenes/player_controls_settings.tscn")

func _ready() -> void:
	update()
	BUS.players_changed.connect(update)
	
func update():
	for i in $PanelContainer/All/KeybindingsScroll/VBox/Players.get_children():
		i.queue_free()
	
	for i in range(GLOB.settings.player_settings.size()):
		var player_controls = player_controls_scene.instantiate()
		player_controls.player = i
		$PanelContainer/All/KeybindingsScroll/VBox/Players.add_child(player_controls)
		player_controls.refresh()

func _on_back_button_pressed() -> void:
	settings_menu_closed.emit()
	queue_free()


func _on_add_player_pressed() -> void:
	GLOB.settings.player_settings.push_back(PlayerSettings.new())
	BUS.players_changed.emit()


func _on_return_pressed() -> void:
	settings_menu_closed.emit()
	queue_free()


func _on_button_pressed() -> void:
	GLOB.settings.fullscreen = not GLOB.settings.fullscreen
