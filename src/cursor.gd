class_name Cursor
extends Node2D

@export var player_id := 0
@onready var growth_area: Area2D = $GrowthArea
@onready var mushroom_scene := preload("res://scenes/mushroom.tscn")
@onready var terrain: TileMapLayer = get_parent().get_node("Terrain") # yeah, whatever, it's a game jam

const radius := 50.0
const growth_speed := 100.0
const starting_hp := 20

# TODO yeah, not perfect, change to final resolution
const MAP_WIDTH := 1920
const MAP_HEIGHT := 1080

var my_mushrooms: Array[Mushroom] = []

func _ready():
	GLOB.all_cursors[player_id] = self
	for i in get_parent().get_children():
		if i is Mushroom:
			if i.player_id == player_id:
				my_mushrooms.push_back(i)


func _process(delta: float) -> void:
	#match player_id:
	#	0: position += Input.get_vector("left1","right1","up1","down1") * 500 * delta
	#	1: position += Input.get_vector("left2","right2","up2","down2") * 500 * delta
	position +=  500 * delta * Input.get_vector(
		"key_left%d" % player_id, 
		"key_right%d" % player_id,
		"key_up%d" % player_id, 
		"key_down%d" % player_id)
	
	var nearby_mushrooms: Array[Mushroom]
	nearby_mushrooms.assign(
		growth_area.get_overlapping_bodies().filter(func(x): \
			return x is Mushroom and x.player_id == player_id
		)
	)
	
	# snap to nearest mushroom if not in range
	var nearest_mushroom: Mushroom = null
	var nearest_mushroom_distance := 999999999.9
	for mushroom in my_mushrooms:
		var new_dist = (global_position - mushroom.global_position).length()
		if new_dist < nearest_mushroom_distance:
			nearest_mushroom = mushroom
			nearest_mushroom_distance = new_dist
	if nearest_mushroom:
		if nearest_mushroom_distance > radius:
			var dir = (global_position - nearest_mushroom.global_position)
			global_position += dir.normalized() * -(nearest_mushroom_distance - radius)

	global_position = global_position.clamp(
		Vector2(radius/2, radius/2),
		Vector2(MAP_WIDTH - radius/2, MAP_HEIGHT - radius/2),
	)

	if nearby_mushrooms.size() == 0:
		return
	
	var growth_factor := growth_speed/nearby_mushrooms.size()
	for mushroom in nearby_mushrooms:
		mushroom.hp += growth_factor * delta
		if mushroom.hp > mushroom.max_hp:
			if try_spawn_mushroom(nearby_mushrooms):
				mushroom.hp -= starting_hp
			else:
				mushroom.hp = mushroom.max_hp
	

func try_spawn_mushroom(nearby_mushrooms: Array[Mushroom]) -> bool:
	for i in range(100):
		var offset = Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
		if offset.length() > radius:
			continue
		
		var new_pos = global_position + offset
		
		var neighboring = false
		var colliding = false
		for mushroom in nearby_mushrooms:
			var dist = (mushroom.global_position - new_pos).length()
			if dist < (mushroom.neighbor_range*2):
				neighboring = true
				break
		
		for mushroom in GLOB.all_mushrooms:
			var dist = (mushroom.global_position - new_pos).length()
			if dist < (mushroom.radius*2):
				colliding = true
				break
		
		var terrain_coords = terrain.local_to_map(new_pos)
		var terrain_data = terrain.get_cell_tile_data(terrain_coords)
		if not terrain_data:
			continue
		else:
			var fertility = terrain_data.get_custom_data("fertility")
			if fertility is float and fertility < 0.0001:
				continue
		
		if not neighboring or colliding:
			continue
		
		# actually spawn
		var new_mushroom: Mushroom = mushroom_scene.instantiate()
		new_mushroom.global_position = new_pos
		new_mushroom.hp = starting_hp
		new_mushroom.player_id = player_id
		add_sibling(new_mushroom)
		
		my_mushrooms.push_back(new_mushroom)
		new_mushroom.tree_exiting.connect(func(): my_mushrooms.erase(new_mushroom))
		new_mushroom.on_spawn()
		return true
	return false

func _draw():
	draw_circle(Vector2(0,0), radius, Color.GREEN, false, 5, true)
