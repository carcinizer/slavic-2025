class_name SINGLETON_GLOB
extends Node

var all_mushrooms: Array[Mushroom] = []
var all_cursors: Dictionary[int, Cursor] = {}

@onready var settings: Settings = load("user://settings.tres")

func _ready() -> void:
	# update fullscreen
	(func(): settings.fullscreen = settings.fullscreen).call_deferred()
	
	BUS.players_changed.connect(refresh_players)
	
	if settings == null: # No save file
		settings = Settings.new()
		settings.resource_path = "user://settings.tres"
		var p1 = PlayerSettings.new()
		p1.key_up = InputEventKey.new()
		p1.key_up.keycode = KEY_W
		p1.key_down = InputEventKey.new()
		p1.key_down.keycode = KEY_S
		p1.key_left = InputEventKey.new()
		p1.key_left.keycode = KEY_A
		p1.key_right = InputEventKey.new()
		p1.key_right.keycode = KEY_D
		settings.player_settings.push_back(p1)
		
		var p2 = PlayerSettings.new()
		p2.key_up = InputEventKey.new()
		p2.key_up.keycode = KEY_UP
		p2.key_down = InputEventKey.new()
		p2.key_down.keycode = KEY_DOWN
		p2.key_left = InputEventKey.new()
		p2.key_left.keycode = KEY_LEFT
		p2.key_right = InputEventKey.new()
		p2.key_right.keycode = KEY_RIGHT
		settings.player_settings.push_back(p2)
		
		BUS.players_changed.emit()
	
	refresh_players()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		GLOB.settings.fullscreen = not GLOB.settings.fullscreen

func refresh_players():
	ResourceSaver.save(settings)
	for id in range(settings.player_settings.size()):
		for field in ["key_left", "key_down", "key_up", "key_right"]:
			if not InputMap.has_action("%s%d" % [field, id]):
				InputMap.add_action("%s%d" % [field, id])
			InputMap.action_erase_events("%s%d" % [field, id])
			
			var event = settings.player_settings[id].get(field)
			if event != null:
				InputMap.action_add_event("%s%d" % [field, id], event)
	
	
