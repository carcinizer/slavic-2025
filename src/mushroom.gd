class_name Mushroom
extends StaticBody2D

@export var player_id := 0
@export var hp := 20.0
## Treshold to which the mushrom will decay if grown beyond it
@export var max_growth := 100.0
@export var max_hp := 120.0
@export var growth_speed := 10.0
## HP/s lost if hp > max_growth
@export var overgrowth_decay_speed := 0
@export var radius := 25
@export var explosion_radius := 150

@export var time_until_starts_dying := 3.0
@export var death_speed := 0.04

var time_since_spawn = 0
var should_check_for_connections = false
var my_tree: LifeTree = null
var my_cursor: Cursor = null

const neighbor_range := 70.0
const sprite_variants_number := 4

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

	## Set explosion area
	$ExplosionArea/CollisionShape2D.shape.radius = explosion_radius

func on_spawn():
	my_cursor = GLOB.all_cursors[player_id]
	should_check_for_connections = true
	time_since_spawn = 0
	for tree in GLOB.all_trees:
		tree.get_mushrooms_in_area()

func die():
	queue_free()
	GLOB.all_mushrooms.erase(self)
	my_cursor.my_mushrooms.erase(self)

func _physics_process(_delta: float):
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
	if should_check_for_connections:
		check_for_connections()

	## Overgrowing
	if hp >= max_hp:
		explode()
	if hp >= max_growth:
		#$ExplosionArea.monitoring = true
		hp -= overgrowth_decay_speed * _delta
	#else: $ExplosionArea.monitoring = false
	print($ExplosionArea.has_overlapping_bodies())


func explode():
	### Create an Area2D child
	#var exploding_area: Area2D = Area2D.new()
	#add_child(exploding_area)
	#var collision_shape: CollisionShape2D = CollisionShape2D.new()
	#exploding_area.add_child(collision_shape)
	#var shape: CircleShape2D = CircleShape2D.new()
	#shape.radius = explosion_radius
	#collision_shape.shape = shape

	## Get overlapping mushrooms
	#var hits: Array[Mushroom]
	var collisions_in_range: Array[Node2D] = \
	$ExplosionArea.get_overlapping_bodies()#.filter(
		#func(x): return x is Mushroom)
	#hits.assign(collisions_in_range)

	## Affect every mushroom in range
	
	for shroom in collisions_in_range:
		shroom.die()
	
	## TODO Visual effects
	
	die()


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
				check_area(othersareas)
		if obj is LifeTree:
			my_tree = obj
			break

func check_for_connections():
	var areas = get_node("NeighborRange").get_overlapping_areas()
	checked_mushrooms = []
	check_area(areas)
	queue_redraw()
