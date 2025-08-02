extends HBoxContainer

@export var text: String = "name"
@export var player: int = -1
@export var player_settings_field: String = "key_up"

signal any_action_pressed


func refresh(id: int) -> void:
	player = id
	$ActionLabel.text = text
	update_button_text()


func update_button_text():
	if GLOB.settings.player_settings[player].get(player_settings_field) != null:
		$KeyChangeButton.text = GLOB.settings.player_settings[player].get(player_settings_field).as_text()
	else:
		$KeyChangeButton.text = "<none>"


func update_value():
	var key = await any_action_pressed
	if key is InputEventKey and key.keycode == KEY_ESCAPE:
		return
	if GLOB.settings.is_keybinding_taken(key):
		print("Keybinding already taken")
		return
	GLOB.settings.player_settings[player].set(player_settings_field, key)
	BUS.players_changed.emit()


func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventJoypadButton:
		any_action_pressed.emit(event)
