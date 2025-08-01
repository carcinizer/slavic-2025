class_name Cursor
extends Node2D

@export var player_id := 0
@onready var growth_area: Area2D = $GrowthArea
@onready var mushroom_scene := preload("res://scenes/mushroom.tscn")

const radius := 100.0
const growth_speed := 100.0
const starting_hp := 20

var mushrooms: Array[Mushroom] = []

func _ready():
	for i in get_parent().get_children():
		if i is Mushroom:
			mushrooms.push_back(i)


func _process(delta: float) -> void:
	position += Input.get_vector("left","right","up","down") * 500 * delta
	
	var nearby_mushrooms: Array[Mushroom]
	nearby_mushrooms.assign(
		growth_area.get_overlapping_bodies().filter(func(x): return x is Mushroom)
	)
	
	print(nearby_mushrooms)
	if nearby_mushrooms.is_empty():
		var nearest_mushroom: Mushroom = null
		var distance := 999999999.9
		for mushroom in mushrooms:
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
			if try_spawn_mushroom():
				mushroom.hp -= starting_hp
			else:
				mushroom.hp = mushroom.max_hp
	

func try_spawn_mushroom() -> bool:
	for i in range(100):
		var offset = Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
		if offset.length() > radius:
			continue
		
		var new_pos = global_position + offset
		
		var found = true
		for mushroom in mushrooms:
			var dist = (mushroom.global_position - new_pos).length()
			if dist < (mushroom.radius*2) or dist > (mushroom.neighbor_range*2):
				found = false
		
		if not found:
			continue
		
		# actually spawn
		var new_mushroom = mushroom_scene.instantiate()
		new_mushroom.global_position = new_pos
		new_mushroom.hp = starting_hp
		new_mushroom.player_id = player_id
		add_sibling(new_mushroom)
		mushrooms.push_back(new_mushroom)
		return true
	return false

func _draw():
	draw_circle(Vector2(0,0), radius, Color.GREEN, false, 5, true)
