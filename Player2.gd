extends Player

var mode = 0

func IA():
	pass
	
func control():
	if Input.is_action_just_pressed('ui_ia'):
		mode += 1
	
	if mode % 3 == 0:
		return .control()
	elif mode % 3 == 1:
		return IA()
	else:
		return
