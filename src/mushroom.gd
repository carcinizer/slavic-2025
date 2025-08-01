class_name Mushroom
extends Node2D

@export var player_id := 0
@export var hp := 20.0
@export var max_hp := 100.0
@export var growth_speed := 10.0
@export var radius := 25

const neighbor_range := 70.0

func _process(_delta: float):
	var c = Color.WHITE if player_id == 0 else Color.RED
	modulate = c.darkened(1.0 - hp/max_hp)
