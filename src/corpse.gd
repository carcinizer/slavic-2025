class_name LifeCorpse
extends StaticBody2D

@export var hp := 100.0
@export var max_hp := 100.0
@export var radius := 100.0
@export var sprite_variant : int = 0

var dead = false

@export var death_speed := 0.01

var checked_mushrooms: Array[Mushroom] = []
var my_connected_mushrooms: Array[Mushroom] = []
var max_connected_mushrooms := 30

const sprite_variants_number := 2

func check_area(areas: Array[Area2D]):
	for a in areas:
		var obj = a.get_parent()
		if obj is Mushroom and !(obj in checked_mushrooms):
			obj.connected_to_a_tree = true
			obj.queue_redraw()
			checked_mushrooms.push_back(obj)
			var othersareas = a.get_overlapping_areas()
			check_area(othersareas)

func check_for_connections():
	var areas = get_node("NeighborRange").get_overlapping_areas()
	checked_mushrooms = []
	check_area(areas)
	
func _ready() -> void:
	sprite_variant *= 2
	var sprite = get_node("Sprite") as Sprite2D
	sprite.frame = sprite_variant
	#var flip = randi_range(0,1)
	#if flip == 1:
	#	sprite.flip_h = true
	GLOB.all_lifelines.push_back(self)

func die():
	dead = true
	GLOB.all_lifelines.erase(self)
	var sprite = get_node("Sprite") as Sprite2D
	sprite.frame += 1;

func _process(_delta: float):
	if dead:
		return
	modulate.r = hp/max_hp
	modulate.g = hp/max_hp
	modulate.b = hp/max_hp
	if my_connected_mushrooms.size() > 0:
		hp -= death_speed * my_connected_mushrooms.size() * _delta
	if hp <= 0:
		die()

	if Input.is_action_just_pressed("debug"):
		check_for_connections()

	$NeighborRange/CollisionShape2D.queue_redraw()
