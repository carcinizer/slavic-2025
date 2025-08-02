class_name Settings
extends Resource

@export var player_settings: Array[PlayerSettings] = []
@export var fullscreen: bool = false:
	set(new):
		fullscreen = new
		set_fullscreen.call_deferred()
		if resource_path != "":
			ResourceSaver.save(self)

func set_fullscreen():
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func is_keybinding_taken(event: InputEvent) -> bool:
	return player_settings.any(
		func(x: PlayerSettings): return x.is_keybinding_taken(event)
	)
