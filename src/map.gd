class_name Map
extends Node2D

@onready var mushroom_scene = preload("res://scenes/mushroom.tscn")
@onready var cursor_scene = preload("res://scenes/cursor.tscn")

func _ready():
	var spawn_locations = get_node("SpawnLocations")

	for player_id in range(GLOB.settings.player_settings.size()):
		GLOB.players_in_the_game += 1
		var mushroom: Mushroom = mushroom_scene.instantiate()
		mushroom.player_id = player_id

		var pos = spawn_locations.get_child(player_id - 1).position

		mushroom.position = pos
		add_child(mushroom)
		
		var cursor: Cursor = cursor_scene.instantiate()
		cursor.player_id = player_id
		cursor.position = pos
		cursor.color = GLOB.player_colors[player_id]
		add_child(cursor)

	GLOB.game_in_progress = true
