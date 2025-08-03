class_name Map
extends Node2D

@onready var mushroom_scene = preload("res://scenes/mushroom.tscn")
@onready var cursor_scene = preload("res://scenes/cursor.tscn")

# TODO VERY TEMP
@export var mushroom_positions: Array[Vector2] = [
	Vector2(200, 300),
	Vector2(400, 500),
	Vector2(100, 600),
	Vector2(700, 400),
]

func _ready():
	for player_id in range(GLOB.settings.player_settings.size()):
		GLOB.players_in_the_game += 1
		var mushroom: Mushroom = mushroom_scene.instantiate()
		mushroom.player_id = player_id
		mushroom.position = mushroom_positions[player_id]
		add_child(mushroom)
		
		var cursor: Cursor = cursor_scene.instantiate()
		cursor.player_id = player_id
		cursor.position = mushroom_positions[player_id]
		cursor.color = GLOB.player_colors[player_id]
		add_child(cursor)

	GLOB.game_in_progress = true
