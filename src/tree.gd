class_name LifeTree
extends StaticBody2D

@export var hp := 100.0
@export var max_hp := 100.0
@export var radius := 100.0

@export var time_until_starts_dying := 3.0
@export var death_speed := 0.04

var my_connected_mushrooms: Array[Mushroom] = []
var max_connected_mushrooms := 30
var min_connected_mushrooms := 10

var dead = false
var time_since_spawn = 0

var mushrooms_in_area := 0
const mushrooms_needed_in_area := 10

const sprite_variants_number := 3

func get_mushrooms_in_area():
	#mushrooms_in_area = 0
	var areas = get_node("NeighborRange").get_overlapping_areas()
	for a in areas:
		var obj = a.get_parent()
		if obj is Mushroom:
			#mushrooms_in_area += 1
			obj.send_tree_pulse(self, GLOB.frame)
		#queue_redraw()

func _ready() -> void:
	var sprite_variant := randi_range(0,sprite_variants_number - 1)
	var sprite = get_node("Sprite") as Sprite2D
	sprite.frame = sprite_variant
	var flip = randi_range(0,1)
	if flip == 1:
		sprite.flip_h = true
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
	if my_connected_mushrooms.size() < min_connected_mushrooms and time_since_spawn > time_until_starts_dying:
		hp -= death_speed
	if hp <= 0:
		die()
	queue_redraw()

	mushrooms_in_area = 0

	get_mushrooms_in_area()

func send_mushroom_pulse():
	mushrooms_in_area += 1

var arc_width = 20

func _draw():
	var rad = get_node("NeighborRange/CollisionShape2D").shape.radius
	# draw_arc(Vector2(0,0),rad, 0, TAU * mushrooms_in_area / mushrooms_needed_in_area, 40, Color.LAWN_GREEN, 4, true )
	draw_arc(Vector2(0,0),rad, 0, TAU * my_connected_mushrooms.size() / min_connected_mushrooms, 40, Color.GREEN, arc_width, true )
	if my_connected_mushrooms.size() > min_connected_mushrooms:
		draw_arc(Vector2(0,0),rad + arc_width, 0, TAU * (my_connected_mushrooms.size() - min_connected_mushrooms) / (max_connected_mushrooms - min_connected_mushrooms), 40, Color.GREEN, arc_width, true )
