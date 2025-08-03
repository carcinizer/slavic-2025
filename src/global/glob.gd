class_name SINGLETON_GLOB
extends Node

var all_mushrooms: Array[Mushroom] = []
var all_trees: Array[LifeTree] = []
var all_lifelines: Array[StaticBody2D] = []
var all_cursors: Dictionary[int, Cursor] = {}
var player_colors: Array[Color] = [Color.REBECCA_PURPLE, Color.DARK_RED, Color.LIGHT_YELLOW, Color.DIM_GRAY]
var players_in_the_game = 0
@onready var settings: Settings = load("user://settings.tres")

var debug_mushrooms = 0

# i would have sworn that godot had something like this built in
var frame = 0

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

var time_since_spawn = 0
var game_in_progress = false

func _process(delta: float) -> void:
	time_since_spawn += delta
	if Input.is_action_just_pressed("fullscreen"):
		GLOB.settings.fullscreen = not GLOB.settings.fullscreen
	frame += 1
	if game_in_progress and \
	players_in_the_game <= 1:
		end_game()

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


func end_game() -> void:
	game_in_progress = false
	const end_game_screen_scene: PackedScene = preload("res://scenes/end_game_screen.tscn")
	var end_game_sceen_instance: GameOverScreen = end_game_screen_scene.instantiate() as GameOverScreen
	# You can set a custom game over message by setting this var now
	end_game_sceen_instance.text = "GAME OVER"
	get_tree().root.add_child(end_game_sceen_instance)
	GLOB.players_in_the_game = 0
