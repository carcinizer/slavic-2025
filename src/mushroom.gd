class_name Mushroom
extends StaticBody2D

@export var player_id := 0
@export var hp := 20.0
## Treshold to which the mushrom will decay if grown beyond it
@export var max_growth := 100.0
@export var max_hp := 150.0
## HP/s lost if hp > max_growth
@export var overgrowth_decay_speed := 0
@export var radius := 25
@export var explosion_radius := 150
@export var scale_multiplier := 1.4

@export var time_until_starts_dying := 3.0
@export var death_speed := 10

@export var sprite: Sprite2D

@onready var explosion_particles_scene = preload("res://scenes/explosion_particles.tscn")

var time_since_spawn = 0
var should_check_for_connections = false
var my_lifeline: StaticBody2D = null
var my_cursor: Cursor = null

var exploding = false

var nearby_mushrooms: Array[Mushroom]


const neighbor_range := 70.0
const sprite_variants_number := 4

var target_rotation = 0
const rotation_threshold = 0.01
const tree_pulse_coyote_time := 10 # frames

var latest_pulse: int
var latest_time_pulse: int
var latest_pulse_source: Variant
var should_pass_pulse := false

@export var supplied_by_a_tree := false

@onready var prev_hp = hp

# TODO VERY TEMP
const colors = [
	Color.WHITE,
	Color.RED,
	Color.GREEN,
	Color.BLUE
]

func _ready() -> void:
	sprite.scale = Vector2.ZERO
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
	$NeighborRange.area_exited.connect(func(x): \
		if x.get_parent() is Mushroom and x.get_parent().player_id == player_id: \
			nearby_mushrooms.erase(x.get_parent())
	)


	## Set explosion area
	$ExplosionArea/CollisionShape2D.shape.radius = explosion_radius

func on_spawn():
	my_cursor = GLOB.all_cursors[player_id]
	should_check_for_connections = true
	time_since_spawn = 0

func die():
	queue_free()
	GLOB.all_mushrooms.erase(self)
	if is_instance_valid(my_cursor):
		my_cursor.my_mushrooms.erase(self)

func _process(_delta: float):
	if !exploding:
		time_since_spawn += _delta
	else:
		exploding_time += _delta
		queue_redraw()
	if my_lifeline == null and time_since_spawn > time_until_starts_dying:
		hp -= death_speed * _delta
	if hp <= 0:
		die()

	# var c = colors[player_id]
	var scale_scalar = ((hp/max_hp) * 0.85 + 0.15) * scale_multiplier
	sprite.scale = lerp(sprite.scale, Vector2(scale_scalar, scale_scalar), 0.1)
	if abs(rotation - target_rotation) < rotation_threshold:
		target_rotation = randfn(0, 0.2) * (hp/max_hp) # ca. 11 deg std deviation
	
	rotation = lerp(rotation, target_rotation, abs(prev_hp-hp) * 0.1)

	prev_hp = hp

	if latest_pulse > GLOB.frame - tree_pulse_coyote_time and supplied_by_a_tree:
		my_lifeline = latest_pulse_source
		if not is_instance_valid(my_lifeline):
			my_lifeline = null
		if my_lifeline:
			my_lifeline.send_mushroom_pulse()
	else:
		my_lifeline = null
	
	var skew_amplitude = remap(hp, max_growth, max_hp, 1, 10) if hp > max_growth else 0.0
	$Sprite.skew = deg_to_rad(sin(time_since_spawn * 30) * skew_amplitude)
	if my_lifeline:
		modulate = Color.WHITE.darkened(0.5 * sin(latest_time_pulse * 0.05))
	else:
		modulate = Color.WHITE
	
	## Overgrowing
	if hp >= max_hp:
		explode()
	if hp >= max_growth:
		hp -= overgrowth_decay_speed * _delta
	
	if should_pass_pulse:
		for i in nearby_mushrooms:
			if is_instance_valid(latest_pulse_source) and is_instance_valid(i):
				i.send_tree_pulse(latest_pulse_source, latest_pulse, 10)
	should_pass_pulse = false
	# queue_redraw()

func kill_by_explosion():
	var hits: Array[Mushroom]
	var collisions_in_range: Array[Node2D] = \
	$ExplosionArea.get_overlapping_bodies().filter(
		func(x): return x is Mushroom and x != self)
	print(collisions_in_range.size())
	hits.assign(collisions_in_range)

	## Affect every mushroom in range
	for shroom in collisions_in_range:
		shroom.die()

func send_tree_pulse(obj: Variant, frame: int, chain_timing: int = 0):
	if frame > latest_pulse:
		latest_pulse = frame
		latest_time_pulse = frame + chain_timing # basically just pulse accounting for a "chain" so that the effect "spreads" from the tree
												 # actually not, it's apparently not working
		latest_pulse_source = obj
		obj.latest_time_pulse = latest_time_pulse
		should_pass_pulse = true

var exploding_time = 0
func explode():
	if exploding:
		return
	exploding = true
	
	var particles = explosion_particles_scene.instantiate()
	particles.emitting = true
	particles.global_position = global_position
	particles.modulate = GLOB.player_colors[player_id].lightened(0.5)
	add_sibling(particles)
	
	kill_by_explosion()
	await get_tree().create_timer(1).timeout
	die()

func _exit_tree() -> void:
	GLOB.all_mushrooms.erase(self)

func _draw():
	# var rad = get_node("NeighborRange/CollisionShape2D").shape.radius
	# var color = Color.GREEN if my_lifeline != null else Color.RED 
	# draw_circle(Vector2(0,0), rad, color, false, 1, true)
	# if my_lifeline:
	# 	draw_string(ThemeDB.fallback_font, Vector2(0,0), my_lifeline.name)

	if exploding:
		var rad = get_node("ExplosionArea/CollisionShape2D").shape.radius
		var alpha = remap(exploding_time,0,1,.5,0)
		draw_circle(Vector2(0,0), rad, Color(1,1,1,alpha), true, -1, true)

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
		if obj is LifeTree or obj is LifeCorpse:
			if !(self in obj.my_connected_mushrooms)and obj.my_connected_mushrooms.size() < obj.max_connected_mushrooms and !obj.dead:
				my_lifeline = obj
				obj.my_connected_mushrooms.push_back(self)
				break

func check_for_connections():
	var areas = get_node("NeighborRange").get_overlapping_areas()
	checked_mushrooms = []
	check_area(areas)
	queue_redraw()
