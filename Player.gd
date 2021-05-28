extends KinematicBody2D

class_name Player
# Declare member variables here. Examples:
var velocity = Vector2()
var speed = 800
var collided_with = ""
var init_jump = 0
var JUMP = -1500
var jump_force = JUMP
var dance_flag = 0
var hxnd_flag = 0

var UP
var RIGHT
var LEFT
var DOWN
var DOWN_RELEASE

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
	elif hxnd_flag == 1:
		$Player_Sprite.animation = "hxnd"
	elif hxnd_flag == 2:
		$Player_Sprite.animation = "hxd"
	elif hxnd_flag == 3:
		$Player_Sprite.animation = "hxd_end"
	elif(velocity.x != 0):
		$Player_Sprite.animation = "walk"
	elif dance_flag == 1:
		$Player_Sprite.animation = "chapeu"
	elif dance_flag == 2:
		$Player_Sprite.animation = "kitty_dance"
	else:
		$Player_Sprite.animation = "idle"
	pass

func control():
	RIGHT =  Input.is_action_pressed('ui_right')
	UP =  Input.is_action_just_pressed('ui_up')
	LEFT =  Input.is_action_pressed('ui_left')
	DOWN = Input.is_action_pressed('ui_down')
	DOWN_RELEASE = Input.is_action_just_released("ui_down")
	
	if RIGHT or LEFT or UP or DOWN:
		dance_flag = 0
	elif dance_flag < 1 and  Input.is_action_just_pressed('ui_dance'):
		dance_flag = 1
		
	pass

func dance():
	if dance_flag == 0:
		return
	if $Player_Sprite.frame == $Player_Sprite.frames.get_frame_count("chapeu") -1:
		dance_flag = 2
		return

func is_finished(animacao):
	return $Player_Sprite.frame == $Player_Sprite.frames.get_frame_count(animacao) -1;

func jump():
	
	#se o pulo não estiver sendo feito, só ignorar
	if init_jump == 0:
		return
	# ainda vai iniciar o pulo
	if init_jump == -1:
		# a animação do pulo acabou
		if is_finished("prejump"):
			#iniciar o movimento de pulo
			init_jump = 1
		return
	# se bater no chão
	if collided_with == "Chao" and init_jump == 2:
		init_jump = 3
		return
	if init_jump == 3 and  is_finished("posjump"):
		init_jump = 0
		jump_force = JUMP
		return
		
		
		
	jump_force += 50
	if jump_force == -JUMP:
		init_jump = 2
	velocity.y = jump_force
	pass

func normalize_wall():
	if collided_with == 'Parede_D':
		velocity.x = -5
	elif collided_with == 'Parede_E':
		velocity.x = 5 
	move_and_slide(velocity)
	pass

func get_input():
	velocity = Vector2()
	control()
	# Detect up/down/left/right keystate and only move when pressed.
	if hxnd_flag == 3 and is_finished("hxd_end"):
		hxnd_flag = 0	
	if DOWN_RELEASE and hxnd_flag != 0:
		hxnd_flag = 3
	elif DOWN:
		if hxnd_flag == 0:
			hxnd_flag = 1
		if hxnd_flag == 1 and is_finished("hxnd"):
			hxnd_flag = 2
	else:
		if RIGHT:
			velocity.x += 1
		if LEFT:
			velocity.x -= 1
		if UP and init_jump == 0:
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
	dance()
	var collision = move_and_collide(velocity * delta)
	if collision:
		collided_with = collision.collider.name
		normalize_wall()
		#print("I collided with ", collision.collider.name)
	
	pass
