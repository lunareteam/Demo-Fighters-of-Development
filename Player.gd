extends KinematicBody2D

class_name Player
# Declare member variables here. Examples:
var velocity = Vector2()
var speed = 800
var collided_with = ""
var init_jump = 0
var JUMP = -1000
var jump = JUMP
var dance = 0

var UP
var RIGHT
var LEFT

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func animate():
	if init_jump == 3:
		$Player_Sprite.animation = "posjump"
	elif init_jump == -1:
		$Player_Sprite.animation = "prejump"
	elif init_jump == 1:
		$Player_Sprite.animation = "jump"
	elif(velocity.x != 0):
		$Player_Sprite.animation = "walk"
	elif dance == 1:
		$Player_Sprite.animation = "chapeu"
	elif dance == 2:
		$Player_Sprite.animation = "kitty_dance"
	else:
		$Player_Sprite.animation = "idle"
	pass

func control():
	RIGHT =  Input.is_action_pressed('ui_right')
	UP =  Input.is_action_just_pressed('ui_up')
	LEFT =  Input.is_action_pressed('ui_left')
	
	if RIGHT or LEFT or UP:
		dance = 0
	elif dance < 1 and  Input.is_action_just_pressed('ui_dance'):
		dance = 1
		
	pass

func dance():
	if dance == 0:
		return
	if $Player_Sprite.frame == $Player_Sprite.frames.get_frame_count("chapeu") -1:
		dance = 2
		return

func jump():
	
	#se o pulo não estiver sendo feito, só ignorar
	if init_jump == 0:
		return
	# ainda vai iniciar o pulo
	if init_jump == -1:
		# a animação do pulo acabou
		if $Player_Sprite.frame == $Player_Sprite.frames.get_frame_count("prejump") -1:
			#iniciar o movimento de pulo
			init_jump = 1
		return
	# se bater no chão
	if collided_with == "Chao" and init_jump == 2:
		init_jump = 3
		return
	if init_jump == 3 and  $Player_Sprite.frame == $Player_Sprite.frames.get_frame_count("posjump") -1:
		init_jump = 0
		jump = JUMP
		return
		
		
		
	jump += 50
	if jump == -JUMP:
		init_jump = 2
	velocity.y = jump
	pass

func normalize_wall():
	pass

func startjump():
	init_jump = 1
	pass

func get_input():
	velocity = Vector2()
	control()
	# Detect up/down/left/right keystate and only move when pressed.
	if RIGHT:
		velocity.x += 1
	if LEFT:
		velocity.x -= 1
	if Input.is_action_just_pressed('ui_up') and init_jump == 0:
		$Player_Sprite.connect("finished", self, "startjump")
		init_jump = -1

	velocity = velocity.normalized() * speed
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	animate()
	pass

func _physics_process(delta):
	get_input()
	if(collided_with != "Chao" and init_jump == 0):
		velocity.y = 100
	jump()
	normalize_wall()
	dance()
	var collision = move_and_collide(velocity * delta)
	if collision:
		collided_with = collision.collider.name
		#print("I collided with ", collision.collider.name)
	
	#print(init_jump)
	pass
