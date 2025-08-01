extends StaticBody2D

@export var hp := 20.0
@export var max_hp := 100.0
@export var radius := 100.0

func _process(_delta: float):
	modulate.r = hp/max_hp
	modulate.g = hp/max_hp
	modulate.b = hp/max_hp
