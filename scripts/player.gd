extends CharacterBody2D

@export var speed := 500
@export var jump_force := 500
@export var gravity := 600

var forced_move = false
var forced_velocity_x = 0
var is_jumping_action = false

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if forced_move:
		velocity.x = forced_velocity_x
	else:
		var dir = Input.get_axis("ui_left", "ui_right")
		velocity.x = dir * speed

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = -jump_force

	move_and_slide()

func boost_jump():
	velocity.y = -jump_force * 1.5

func jump_with_side(dir):
	if is_jumping_action:
		return

	is_jumping_action = true

	boost_jump()

	await get_tree().create_timer(0.9).timeout

	forced_move = true
	forced_velocity_x = dir * speed

	await get_tree().create_timer(0.25).timeout

	forced_move = false
	forced_velocity_x = 0

	is_jumping_action = false
