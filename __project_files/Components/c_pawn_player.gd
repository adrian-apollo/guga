class_name CPawnPlayer extends CPawn

@export_group( "Move config")
@export var move_scale:float = 1.0
@export var speed:float = 1.0

@export_group("Input")
@export var imc:InputMappingContext
@export var ia_fire:InputAction
@export var ia_move:InputAction

var player:Node2D

func event_possess():
	player = owner
	tree.execute( owner, &"_activate_spawner", [])
	
	EnhancedInput.add_context( imc )
	EnhancedInput.debug_overlay = true

	ia_move.triggered.connect(move)
	ia_fire.triggered.connect(fire)

func event_unpossess():
	EnhancedInput.remove_context( imc )

func fire( _value ):
	tree.execute( owner, &"trigger", [])
	
func move( _value ):
	var calc:float = player.global_position.x + speed * _value * player.get_physics_process_delta_time() * move_scale
	if calc > 10 and calc < 640:
		player.global_position.x = calc
