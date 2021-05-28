extends KinematicBody2D


# Declare member variables here. Examples:
var velocity = Vector2(0,200)
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		print("I collided with ", collision.collider.name)
	pass
