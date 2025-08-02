class_name LifeTree
extends StaticBody2D

@export var hp := 100.0
@export var max_hp := 100.0
@export var radius := 100.0

@export var time_until_starts_dying := 3.0
@export var death_speed := 1
@export var sprite_variant : int

#var my_connected_mushrooms: Array[Mushroom] = []
var max_connected_mushrooms := 30
var min_connected_mushrooms := 10

var latest_time_pulse = 0.0

var dead = false
var time_since_spawn = 0

var mushrooms_in_area := 0
const mushrooms_needed_in_area := 10

const sprite_variants_number := 3

func get_mushrooms_in_area():
	var areas = get_node("NeighborRange").get_overlapping_areas()
	for a in areas:
		var obj = a.get_parent()
		if obj is Mushroom and !dead:
			obj.send_tree_pulse(self, GLOB.frame)
		#queue_redraw()

func _ready() -> void:
	sprite_variant *= 2
	var sprite = get_node("Sprite") as Sprite2D
	sprite.frame = sprite_variant
	GLOB.all_trees.push_back(self)
	GLOB.all_lifelines.push_back(self)

func die():
	queue_free()
	GLOB.all_trees.erase(self)
	GLOB.all_lifelines.erase(self)


func _process(_delta: float):
	modulate.r = hp/max_hp
	modulate.g = hp/max_hp
	modulate.b = hp/max_hp
	time_since_spawn += _delta
	# if mushrooms_in_area < mushrooms_needed_in_area and time_since_spawn > time_until_starts_dying:
	if mushrooms_in_area < min_connected_mushrooms and time_since_spawn > time_until_starts_dying:
		hp -= death_speed * _delta
	if hp <= 0:
		die()
	$NeighborRange/CollisionShape2D.queue_redraw()

	get_mushrooms_in_area()
	if mushrooms_in_area > min_connected_mushrooms:
		modulate = Color.WHITE.darkened(0.1 * sin(latest_time_pulse * 0.05))
	mushrooms_in_area = 0
	
	var shrooms := GLOB.all_mushrooms.duplicate()
	shrooms.sort_custom(_sort_by_distance)
	
	var i = 0
	
	for shroom in shrooms:
		(func(): shroom.supplied_by_a_tree = false).call_deferred() # resetting supplied state every frame
																	# don't do drugs, kids
	for shroom in shrooms:
		if shroom.latest_pulse_source != self or shroom.supplied_by_a_tree:
			shroom.supplied_by_a_tree = true
			continue
			
		shroom.supplied_by_a_tree = true
		i += 1
		if i > max_connected_mushrooms:
			break
	

func send_mushroom_pulse():
	mushrooms_in_area += 1

var arc_width = 20

func _sort_by_distance(a: Mushroom, b: Mushroom) -> bool:
	return (a.global_position - global_position).length() < (b.global_position-global_position).length()
