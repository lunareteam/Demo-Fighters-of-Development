extends KinematicBody2D


# Declare member variables here. Examples:
var velocity = Vector2()
var speed = 800
var collided_with = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_input():
	velocity = Vector2()
	# Detect up/down/left/right keystate and only move when pressed.
	if Input.is_action_pressed('ui_right'):
		velocity.x += 1
	if Input.is_action_pressed('ui_left'):
		velocity.x -= 1
	#if Input.is_action_pressed('ui_down'):
	#    velocity.y += 1
	#if Input.is_action_pressed('ui_up'):
	#    velocity.y -= 1
	velocity = velocity.normalized() * speed
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(velocity.x != 0):
		$Player_Sprite.animation = "walk"
	else:
		$Player_Sprite.animation = "idle"
	pass

func _physics_process(delta):
	get_input()
	if(collided_with != "Chao"):
		velocity.y = 100
	#print(velocity)
	var collision = move_and_collide(velocity * delta)
	if collision:
		collided_with = collision.collider.name
		#print("I collided with ", collision.collider.name)
	pass
