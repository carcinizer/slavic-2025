class_name Mushroom
extends Node2D

@export var player_id := 0
@export var hp := 20.0
@export var max_hp := 100.0
@export var growth_speed := 10.0
@export var radius := 25

@export var time_until_starts_dying := 3.0
@export var death_speed := 0.04

var time_since_spawn = 0
var should_check_for_connections = false
var my_tree: LifeTree = null
var my_cursor: Cursor = null


var nearby_mushrooms: Array[Mushroom]


const neighbor_range := 70.0
const sprite_variants_number := 4

var target_rotation = 0
const rotation_threshold = 0.01
const tree_pulse_coyote_time := 10 # frames

var latest_pulse: int
var latest_pulse_source: LifeTree

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
	nearby_mushrooms.assign(
		$NeighborRange.get_overlapping_areas().filter(func(x): \
			return x.get_parent() is Mushroom and x.get_parent().player_id == player_id
		).map(func(x): x.get_parent())
	)
	$NeighborRange.area_entered.connect(func(x): \
		if x.get_parent() is Mushroom and x.get_parent().player_id == player_id: \
			nearby_mushrooms.push_back(x.get_parent())
	)
	$NeighborRange.area_exited.connect(func(b): nearby_mushrooms.erase(b.get_parent()))


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
	#if should_check_for_connections:
	#	check_for_connections()
	
	if latest_pulse > GLOB.frame - tree_pulse_coyote_time:
		my_tree = latest_pulse_source
		my_tree.send_mushroom_pulse()
	else:
		my_tree = null
	
	modulate = Color.WHITE if latest_pulse % 10 > 5 else Color.WHITE.darkened(0.1)

func send_tree_pulse(obj: LifeTree, frame: int):
	if frame > latest_pulse:
		latest_pulse = frame
		latest_pulse_source = obj
		for i in nearby_mushrooms:
			i.send_tree_pulse(latest_pulse_source, latest_pulse)
		

func _exit_tree() -> void:
	GLOB.all_mushrooms.erase(self)

# func _draw():
# 	var rad = get_node("NeighborRange/CollisionShape2D").shape.radius
# 	var color = Color.GREEN if my_tree != null else Color.RED 
# 	draw_circle(Vector2(0,0), rad, color, false, 1, true)

var checked_mushrooms: Array[Mushroom] = []
