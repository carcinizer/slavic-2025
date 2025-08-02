class_name Settings
extends Resource

@export var player_settings: Array[PlayerSettings] = []

func is_keybinding_taken(event: InputEvent) -> bool:
	return player_settings.any(
		func(x: PlayerSettings): return x.is_keybinding_taken(event)
	)
