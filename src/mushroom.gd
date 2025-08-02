class_name Mushroom
extends Node2D

@export var player_id := 0
@export var hp := 20.0
@export var max_hp := 100.0
@export var growth_speed := 10.0
@export var death_speed := 1.0
@export var radius := 25
@export var connected_to_a_tree := false

const neighbor_range := 70.0

# TODO VERY TEMP
const colors = [
	Color.WHITE,
	Color.RED,
	Color.GREEN,
	Color.BLUE
]

func _ready() -> void:
	GLOB.all_mushrooms.push_back(self)

func _process(_delta: float):
	# if !connected_to_a_tree:
	# 	hp -= death_speed
	# if hp <= 0:
	# 	queue_free()
	var c = colors[player_id]
	modulate = c.darkened(1.0 - hp/max_hp)

func _exit_tree() -> void:
	GLOB.all_mushrooms.erase(self)

func _draw():
	var rad = get_node("NeighborRange/CollisionShape2D").shape.radius
	var color = Color.GREEN if connected_to_a_tree else Color.RED 
	draw_circle(Vector2(0,0), rad, color, false, 1, true)
