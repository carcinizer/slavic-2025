class_name Map
extends Node2D

@onready var mushroom_scene = preload("res://scenes/mushroom.tscn")
@onready var cursor_scene = preload("res://scenes/cursor.tscn")

func _ready():
	var spawn_locations = get_node("SpawnLocations")

	GLOB.players_in_the_game = 0
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
	# 2 minutes for 2 players, +30s for each extra player
	GLOB.timer = 60 + GLOB.settings.player_settings.size() * 30

func _process(_delta: float):
	var str := ""
	
	for player_id in range(GLOB.all_cursors.size()):
		if not is_instance_valid(GLOB.all_cursors[player_id]):
			continue
		str += "[img]%s[/img][color=%s]%s\t\t" % [
			GLOB.player_sprites[player_id],
			GLOB.player_colors[player_id].to_html(), 
			GLOB.all_cursors[player_id].my_mushrooms.size()
		]
	
	var minutes = ceil(GLOB.timer / 60) - 1
	var seconds = int(GLOB.timer) % 60
	
	$Hud/Scores.text = str
	$Hud/Timer/Min.text = "%d" % [minutes]
	$Hud/Timer/Sec.text = "%02d" % [seconds]
