extends KinematicBody2D

class_name PlayerV2

# Change as necessary
var gravity = 1000
var speed = 400
var JUMP = 1000
var jump_duration = 0.5
var offset = 0.001
var pause = false

# Helpers
var velocity = Vector2()
var collided_with = ""
var init_jump = 0
var dance_flag = 0
var hxnd_flag = 0
var action_busy_list = ["kick_hxd", "kick_pe","soco_pe","soco_hxd"]
var animacao_atual
var animation_time = 0
var jump_timer = 0

# Controlador  de log
var DEBUG = false

#controles
var UP
var RIGHT
var LEFT
var DOWN
var DOWN_RELEASE
var ANIMATOR

# 0 pra nadar
# 1 pra socar
# 2 pra chutar
# 3 pra bloquear
var ACTION = 0

func _ready():
	ANIMATOR = $Sprite/AnimationPlayer
	pass

#TODO descobrir como cronometrar o tempo parado
func micro_pause(delta):
	pause_unpause()
	pass

func pause_unpause():
	if ANIMATOR.is_playing():
		pause = true
		$Sprite/AnimationPlayer.stop(false)
	else:
		pause = false

# funções que ajudam a debugaros controles e flags
func DEBUG_CONTROLS():
	print("L:",LEFT," u:",UP," d:",DOWN," dr:",DOWN_RELEASE," r:",RIGHT,"   a:",ACTION)
	pass

func DEBUG_FLAGS():
	print("jf:",jump_timer," d:",dance_flag," h:",hxnd_flag," j:",init_jump,"   a:",ACTION)
	pass

# função sempre é chamada ao animar, puramente apenas tocar a animação
func play_animation(animation):
	if animation != ANIMATOR.current_animation and ANIMATOR.current_animation != "":	
		animation_time = 0
	ANIMATOR.play(animation)
	pass

# atribui as animações de acordo com as flags
func animate():
	if pause:
		return
	
	if ACTION == 1:
		if hxnd_flag == 0:
			animacao_atual = "soco_pe"
		else:
			animacao_atual = "soco_hxd"
	elif ACTION == 2:
		if hxnd_flag == 0:
			animacao_atual = "kick_pe"
		else:
			animacao_atual = "kick_hxd"
	elif ACTION == 3:
		if hxnd_flag == 0:
			animacao_atual = "block_pe"
		else:
			animacao_atual = "block_hxd"
	#movimentos "normais"
	elif init_jump == 3:
		animacao_atual = "posjump"
	elif init_jump == 1 or init_jump == 2:
		animacao_atual = "jump"
	elif init_jump == -1:
		animacao_atual = "prejump"
	elif hxnd_flag == 1:
		animacao_atual = "hxnd"
	elif hxnd_flag == 2:
		animacao_atual = "hxd"
	elif hxnd_flag == 3:
		animacao_atual = "hxd_end"
	elif(velocity.x != 0):
		animacao_atual = "walk"
	elif dance_flag == 1:
		animacao_atual = "chapeu"
	elif dance_flag == 2:
		animacao_atual = "kitty_dance"
	else:
		animacao_atual = "idle"
	play_animation(animacao_atual)
	pass

# verifica se a animação atual é cancelavel
func is_busy():
	var ta_ocupado = ANIMATOR.current_animation in action_busy_list
	if ta_ocupado and not is_finished(ANIMATOR.current_animation):
		return true
	elif ta_ocupado or "block" in  ANIMATOR.current_animation:
		ACTION = 0
	return false

# funcao feita puramente para pegar os controles
# futuramente será sobrescrita pela IA
func control():
	RIGHT =  Input.is_action_pressed('ui_right')
	UP =  Input.is_action_just_pressed('ui_up')
	LEFT =  Input.is_action_pressed('ui_left')
	DOWN = Input.is_action_pressed('ui_down')
	DOWN_RELEASE = Input.is_action_just_released("ui_down")
	
	DEBUG = Input.is_action_just_pressed("game_debug")
	
	# acoes
	if not is_busy():
		if Input.is_action_just_pressed("game_kick"):
			ACTION = 2
		elif Input.is_action_just_pressed("game_punch"):
			ACTION = 1
		elif Input.is_action_pressed("game_block"):
			ACTION = 3
	
	# danca gatinho, danca
	if RIGHT or LEFT or UP or DOWN or ACTION != 0:
		dance_flag = 0
	elif dance_flag < 1 and  Input.is_action_just_pressed('game_dance'):
		dance_flag = 1
	
	pass

# verifica se o tempo da animação "acabou"
func is_finished(animacao):
	if animacao != ANIMATOR.current_animation:
		return false
	
	return animation_time + offset >= ANIMATOR.current_animation_length

# controla as flags de danca
func dance():
	if dance_flag == 0:
		return
	if is_finished("chapeu"):
		dance_flag = 2
		return

# controla o pulo e suas flags
func jump(delta):
	
	#se o pulo não estiver sendo feito, só ignorar
	if init_jump == 0 or pause:
		return
	# ainda vai iniciar o pulo
	elif init_jump == -1:
		# a animação do pulo acabou
		if is_finished("prejump"):
			#iniciar o movimento de pulo
			init_jump = 1
		elif ACTION != 0:
			init_jump = 0
		return
	# se bater no chão
	elif collided_with == "Chao" and init_jump == 2:
		init_jump = 3
		return
	elif init_jump == 3 and  (is_finished("posjump") or ACTION != 0):
		init_jump = 0
		jump_timer = 0
		return
	elif init_jump == 1 or init_jump == 2:
		if jump_timer > jump_duration/2:
			init_jump = 2
			velocity.y = JUMP
		else:
			velocity.y = -JUMP
		
		jump_timer += delta
	pass

# retira o atrito da parede
func normalize_wall():
	if collided_with == 'Parede_D':
		velocity.x = -5
	elif collided_with == 'Parede_E':
		velocity.x = 5 
	move_and_slide(velocity)
	pass

# dado os controles, essa função executa suas consequencias
func get_input():
	velocity = Vector2()
	control()
	
	var double = 2
	# Detect up/down/left/right keystate and only move when pressed.
	if hxnd_flag == 3 and (is_finished("hxd_end") or ACTION != 0):
		hxnd_flag = 0	
	if DOWN_RELEASE and hxnd_flag != 0:
		hxnd_flag = 3
	elif DOWN:
		if hxnd_flag == 0:
			hxnd_flag = 1
		if hxnd_flag == 1 and (ACTION != 0 or is_finished("hxnd")):
			hxnd_flag = 2
		
		double /= 2
	
	if ACTION == 0:
		if RIGHT:
			velocity.x += 1
		if LEFT:
			velocity.x -= 1
		if UP and init_jump == 0 and not DOWN:
			init_jump = -1

	velocity = velocity.normalized() * speed * (double)
	#print(init_jump)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	animate()
	if not pause:
		animation_time += delta
	pass

# teoricamente é para ter tudo relacionado a fisica do obj
func _physics_process(delta):
	get_input()
	if(collided_with != "Chao" and init_jump == 0):
		velocity.y = gravity
	jump(delta)
	dance()
	collided_with = ""
	if not pause:
		var collision = move_and_collide(velocity * delta)
		if collision:
			collided_with = collision.collider.name
			normalize_wall()
	if DEBUG:
		micro_pause(delta)
		#print("-------------------------------------------------------")
		#print(ANIMATOR.current_animation_position," ",ANIMATOR.current_animation_length," ",animacao_atual)
		#DEBUG_CONTROLS()
		#DEBUG_FLAGS()
		#print(velocity, " t:", transform)
	
	pass
