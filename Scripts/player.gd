extends CharacterBody2D


@export var speed = 300
@export var gravity = 30
@export var jump_force = 300

@onready var ap = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D
@onready var raycastL = $RayCast_Left
@onready var raycastR = $RayCast_Right

var is_crouch_pressed = false
var is_crouching = false

var standing_cshape = preload("res://Resources/knight_standing_cshape.tres")
var crouching_cshape = preload("res://Resources/knight_crouching_cshape.tres")

func _physics_process(delta):
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > 1000:
			velocity.y = 1000;
	
	if Input.is_action_just_pressed("jump"): #&& is_on_floor():
		velocity.y = -jump_force
	
	var hor_direction = Input.get_axis("move_left", "move_right")
	velocity.x = speed * hor_direction
	
	if hor_direction != 0:
		switch_direction(hor_direction)
		
	if Input.is_action_just_pressed("crouch"):
		is_crouch_pressed = true
	elif Input.is_action_just_released("crouch"):
		is_crouch_pressed = false
	
	if is_crouch_pressed:
		crouch()
	if !is_crouch_pressed && !raycastL.is_colliding() && !raycastR.is_colliding():
		stand()
	
	move_and_slide()
	
	update_animations(hor_direction)

func update_animations(hor_direction):
	if is_on_floor():
		if hor_direction == 0:
			if is_crouching:
				ap.play("crouch")
			else:
				ap.play("idle")
		else:
			if is_crouching:
				ap.play("crouch_walk")
			else:
				ap.play("run")
	else:
		if is_crouching == false:
			if velocity.y > 0:
				ap.play("fall")
			else:
				ap.play("jump")
		elif is_crouching:
			ap.play("crouch")

func switch_direction(hor_direction):
	sprite.flip_h = (hor_direction == -1)
	sprite.position.x = hor_direction * 4

func crouch():
	if is_crouching:
		return
	is_crouching = true
	cshape.shape = crouching_cshape
	cshape.position.y = -12

func stand():
	if is_crouching == false:
		return
	else:
		is_crouching = false
	cshape.shape = standing_cshape
	cshape.position.y = -16
