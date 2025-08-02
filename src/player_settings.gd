class_name PlayerSettings
extends Resource

@export var key_up: InputEvent
@export var key_down: InputEvent
@export var key_left: InputEvent
@export var key_right: InputEvent


func is_keybinding_taken(event: InputEvent) -> bool:
	return (key_up.is_match(event) if key_up else false) \
		or (key_down.is_match(event) if key_down else false) \
		or (key_left.is_match(event) if key_left else false) \
		or (key_right.is_match(event) if key_right else false)
