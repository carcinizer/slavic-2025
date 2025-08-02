extends VBoxContainer

@export var player: int = -1


func refresh() -> void:
	$KeybindsContainer/Up.refresh(player)
	$KeybindsContainer/Down.refresh(player)
	$KeybindsContainer/Left.refresh(player)
	$KeybindsContainer/Right.refresh(player)


func _on_remove_pressed() -> void:
	GLOB.settings.player_settings.remove_at(player)
	BUS.players_changed.emit()
