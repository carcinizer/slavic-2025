class_name Mushroom
extends Node2D

@export var player_id := 0
@export var hp := 20.0
@export var max_hp := 100.0
@export var growth_speed := 10.0
@export var time_until_starts_dying := 3.0
@export var death_speed := 0.1
@export var radius := 25
var my_tree: Tree = null
var my_cursor: Cursor = null

const neighbor_range := 70.0
const sprite_variants_number := 4

var time_since_spawn = 0
var target_rotation = 0
const rotation_threshold = 0.01

@onready var prev_hp = hp

# TODO VERY TEMP
const colors = [
	Color.WHITE,
	Color.RED,
	Color.GREEN,
	Color.BLUE
]

func _ready() -> void:
	scale = Vector2.ZERO
	GLOB.all_mushrooms.push_back(self)
	var sprite_variant := randi_range(0,sprite_variants_number-1)
	sprite_variant += sprite_variants_number * player_id
	var sprite = get_node("Sprite") as Sprite2D
	sprite.frame = sprite_variant
	var flip = randi_range(0,1)
	if flip == 1:
		sprite.flip_h = true
	on_spawn.call_deferred()

func on_spawn():
	my_cursor = GLOB.all_cursors[player_id]
	check_for_connections()
	time_since_spawn = 0

func die():
	queue_free()
	GLOB.all_mushrooms.erase(self)
	my_cursor.my_mushrooms.erase(self)

func _process(_delta: float):
	time_since_spawn += _delta
	if my_tree == null and time_since_spawn > time_until_starts_dying:
		hp -= death_speed
	if hp <= 0:
		die()

	# var c = colors[player_id]
	var scale_scalar = hp/max_hp
	scale = lerp(scale, Vector2(scale_scalar, scale_scalar), 0.1)
	if abs(rotation - target_rotation) < rotation_threshold:
		target_rotation = randfn(0, 0.2) * (hp/max_hp) # ca. 11 deg std deviation
	
	rotation = lerp(rotation, target_rotation, abs(prev_hp-hp) * 0.1)
	prev_hp = hp

func _exit_tree() -> void:
	GLOB.all_mushrooms.erase(self)

# func _draw():
# 	var rad = get_node("NeighborRange/CollisionShape2D").shape.radius
# 	var color = Color.GREEN if my_tree != null else Color.RED 
# 	draw_circle(Vector2(0,0), rad, color, false, 1, true)

var checked_mushrooms: Array[Mushroom] = []

func check_area(areas: Array[Area2D]):
	for a in areas:
		var obj = a.get_parent()
		if obj is Mushroom and !(obj in checked_mushrooms):
			obj.queue_redraw()
			checked_mushrooms.push_back(obj)
			if obj.player_id == player_id:
				var othersareas = a.get_overlapping_areas()
				print(obj.name)
				check_area(othersareas)
		if obj is Tree:
			my_tree = obj
			print(obj.name)
			break

func check_for_connections():
	var areas = get_node("NeighborRange").get_overlapping_areas()
	checked_mushrooms = []
	check_area(areas)
	queue_redraw()
