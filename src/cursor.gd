class_name Cursor
extends Node2D

@export var player_id := 0
@onready var growth_area: Area2D = $GrowthArea
@onready var mushroom_scene := preload("res://scenes/mushroom.tscn")

const radius := 100.0
const growth_speed := 100.0
const starting_hp := 20

var all_mushrooms: Array[Mushroom] = []
var my_mushrooms: Array[Mushroom] = []

func _ready():
	BUS.mushroom_spawned.connect(func(x: Mushroom): 
		all_mushrooms.push_back(x)
		x.tree_exiting.connect(all_mushrooms.erase.bind(x))
	)
	
	for i in get_parent().get_children():
		if i is Mushroom:
			all_mushrooms.push_back(i)
			if i.player_id == player_id:
				my_mushrooms.push_back(i)


func _process(delta: float) -> void:
	match player_id:
		0: position += Input.get_vector("left1","right1","up1","down1") * 500 * delta
		1: position += Input.get_vector("left2","right2","up2","down2") * 500 * delta
	
	var nearby_mushrooms: Array[Mushroom]
	nearby_mushrooms.assign(
		growth_area.get_overlapping_bodies().filter(func(x): \
			return x is Mushroom and x.player_id == player_id
		)
	)
	
	# TODO dead code
	if nearby_mushrooms.is_empty():
		var nearest_mushroom: Mushroom = null
		var distance := 999999999.9
		for mushroom in my_mushrooms:
			if mushroom is not Mushroom:
				continue
			var new_dist = (global_position - mushroom.global_position).length()
			if new_dist < distance:
				nearest_mushroom = mushroom
				distance = new_dist
		if nearest_mushroom:
			pass
			#nearby_mushrooms.push_back(nearest_mushroom)
	
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
		
		for mushroom in all_mushrooms:
			var dist = (mushroom.global_position - new_pos).length()
			if dist < (mushroom.radius*2):
				colliding = true
				break
		
		if not neighboring or colliding:
			continue
		
		# actually spawn
		var new_mushroom: Mushroom = mushroom_scene.instantiate()
		new_mushroom.global_position = new_pos
		new_mushroom.hp = starting_hp
		new_mushroom.player_id = player_id
		add_sibling(new_mushroom)
		
		my_mushrooms.push_back(new_mushroom)
		new_mushroom.tree_exiting.connect(my_mushrooms.erase.bind(new_mushroom))
		BUS.mushroom_spawned.emit(new_mushroom)
		return true
	return false

func _draw():
	draw_circle(Vector2(0,0), radius, Color.GREEN, false, 5, true)
