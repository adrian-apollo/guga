class_name CPlayerInput extends ComponentBase

@export var speed:float
@export var scale:float = 1

var player:Node2D

func event_begin():
	player = owner

func event_tick():
	fire()
	move()

func allow_inputs( allow:bool ):
	if allow:
		_reset_tick( TICK_SOURCE.PHYSICS, 0)
		return
	_stop_tick()

func move():
	if Input.is_action_pressed("ArrowLeft"):
		var calc:float = player.global_position.x - speed * player.get_physics_process_delta_time() * scale
		if calc > 25:
			player.global_position.x = calc
	if Input.is_action_pressed("ArrowRight"):
		var calc:float = player.global_position.x + speed * player.get_physics_process_delta_time() * scale
		if calc < 1125:
			player.global_position.x = calc

func fire():
	if Input.is_action_pressed("Fire"):
		tree.execute( owner, &"trigger", [])

func scalate_speed( value:float ):
	scale = value
