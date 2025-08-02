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
	$KeyChangeButton.text = "<press a key/gamepad button>"
	var key = await any_action_pressed
	if key is InputEventKey and key.keycode == KEY_ESCAPE:
		$KeyChangeButton.text = "<cancelled>"
		get_tree().create_timer(1.5).timeout.connect(update_button_text)
		return
	if GLOB.settings.is_keybinding_taken(key):
		$KeyChangeButton.text = "<already taken>"
		get_tree().create_timer(1.5).timeout.connect(update_button_text)
		return
	GLOB.settings.player_settings[player].set(player_settings_field, key)
	BUS.players_changed.emit()


func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventJoypadButton:
		any_action_pressed.emit(event)
