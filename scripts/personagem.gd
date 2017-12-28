extends KinematicBody2D

onready var rayL = get_node("rayL")
onready var rayR = get_node("rayR")
onready var sprite = get_node("sprite")

const GRAVITY = 1100.0

const FLOOR_ANGLE_TOLERANCE = 40
const WALK_FORCE = 600
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 200
const STOP_FORCE = 1300
const JUMP_SPEED = 700
const JUMP_MAX_AIRBORNE_TIME = 0.2

const SLIDE_STOP_VELOCITY = 1.0
const SLIDE_STOP_MIN_TRAVEL = 1.0 

var velocity = Vector2()
var on_air_time = 100
var jumping = false

var prev_jump_pressed = false


func _fixed_process(delta):
	var force = Vector2(0, GRAVITY)
	
	var walk_left = Input.is_action_pressed("move_left")
	var walk_right = Input.is_action_pressed("move_right")
	var jump = Input.is_action_pressed("jump")
	
	var stop = true
	
	if (walk_left):
		if (velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED):
			force.x -= WALK_FORCE
			stop = false
	elif (walk_right):
		if (velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED):
			force.x += WALK_FORCE
			stop = false
	
	if (stop):
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)
		
		vlen -= STOP_FORCE*delta
		if (vlen < 0):
			vlen = 0
		
		velocity.x = vlen*vsign
	
	velocity += force*delta
	
	var motion = velocity*delta
	
	motion = move(motion)
	
	var floor_velocity = Vector2()
	
	if (is_colliding()):
		var n = get_collision_normal()
		
		if (rad2deg(acos(n.dot(Vector2(0, -1)))) < FLOOR_ANGLE_TOLERANCE):
			on_air_time = 0
			floor_velocity = get_collider_velocity()
		
		if (on_air_time == 0 and force.x == 0 and get_travel().length() < SLIDE_STOP_MIN_TRAVEL and abs(velocity.x) < SLIDE_STOP_VELOCITY and get_collider_velocity() == Vector2()):	
			revert_motion()
			velocity.y = 0.0
		else:
			motion = n.slide(motion)
			velocity = n.slide(velocity)
			move(motion)
	
	if (floor_velocity != Vector2()):
		move(floor_velocity*delta)
	
	if (jumping and velocity.y > 0):
		jumping = false
	
	if (on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not prev_jump_pressed and not jumping):
		velocity.y = -JUMP_SPEED
		jumping = true
	
	on_air_time += delta
	prev_jump_pressed = jump
	
	var in_floor = rayL.is_colliding() or rayR.is_colliding()
	
	if walk_right:
		sprite.set_flip_h(false)
	if walk_left:
		sprite.set_flip_h(true)
	if (walk_right or walk_left) and in_floor:
		sprite.play()
	elif (walk_right or walk_left):
		sprite.stop()
		sprite.set_frame(3)
	else:
		sprite.stop()

func _ready():
	set_fixed_process(true)