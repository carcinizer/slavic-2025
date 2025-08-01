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

func _process(_delta: float):
	# if !connected_to_a_tree:
	# 	hp -= death_speed
	# if hp <= 0:
	# 	queue_free()
	modulate.r = hp/max_hp
	modulate.g = hp/max_hp
	modulate.b = hp/max_hp
