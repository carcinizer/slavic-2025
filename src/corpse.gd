class_name LifeCorpse
extends StaticBody2D

@export var hp := 100.0
@export var max_hp := 100.0
@export var radius := 100.0
@export var sprite_variant : int = 0

var latest_time_pulse = 0.0
var dead = false

@export var death_speed := 0.8

var checked_mushrooms: Array[Mushroom] = []
var max_connected_mushrooms := 30
var mushrooms_in_area := 0

const sprite_variants_number := 2
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
	if mushrooms_in_area > 0:
		hp -= death_speed * mushrooms_in_area * _delta
	if hp <= 0:
		die()
		
	get_mushrooms_in_area()
	if mushrooms_in_area > 1:
		modulate = Color.WHITE.darkened(0.1 * sin(latest_time_pulse * 0.05))
	mushrooms_in_area = 0
	
	# yup, ugly code duplication from tree, but whatever, it's a game jam, we're having fun
	var shrooms := GLOB.all_mushrooms.duplicate()
	shrooms.sort_custom(_sort_by_distance)
	
	var i = 0
	
	for shroom in shrooms:
		(func(): shroom.supplied_by_a_tree = false).call_deferred()
	
	for shroom in shrooms:
		if shroom.latest_pulse_source != self or shroom.supplied_by_a_tree:
			#shroom.supplied_by_a_tree = true
			continue
			
		shroom.supplied_by_a_tree = true
		i += 1
		if i > max_connected_mushrooms:
			break
	#if Input.is_action_just_pressed("debug"):
	#	check_for_connections()

	$NeighborRange/CollisionShape2D.queue_redraw()

func send_mushroom_pulse():
	mushrooms_in_area += 1

func _sort_by_distance(a: Mushroom, b: Mushroom) -> bool:
	return (a.global_position - global_position).length() < (b.global_position-global_position).length()
