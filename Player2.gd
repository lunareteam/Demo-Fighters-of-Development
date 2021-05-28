extends KinematicBody2D


# Declare member variables here. Examples:
var velocity = Vector2()
var speed = 1000
var collided_with = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

func _physics_process(delta):
	#get_input()
	velocity.y = 0
	if(collided_with != "Chao"):
		velocity.y = 150
	#print(velocity)
	var collision = move_and_collide(velocity * delta)
	if collision:
		collided_with = collision.collider.name
		#print("I collided with ", collision.collider.name)
	pass
