class_name CPawnPlayer extends CPawn

@export_group( "Move config")
@export var move_scale:float = 1.0
@export var speed:float = 1.0

@export_group("Input")
@export var imc:InputMappingContext
@export var ia_fire:InputAction
@export var ia_move:InputAction

var player:Node2D

var touchui:UIWidgetBase = load( "uid://fpr4sb12vrbi" ).instantiate()
var touch_move:BetterJoystick
var touch_fire:Button

func event_possess():
	tocuh_input()
	player = owner
	tree.execute( owner, &"_activate_spawner", [])
	
	EnhancedInput.add_context( imc )
	#EnhancedInput.debug_overlay = true

	ia_move.triggered.connect(move)
	ia_fire.triggered.connect(fire)

func event_unpossess():
	EnhancedInput.remove_context( imc )
	touchui.queue_free()

func tocuh_input():
	tree.get_gamemode().uis[0].add_widget_to_layer( touchui, &"gameplay_menus" )
	touch_move = touchui.get_child( 0 )
	touch_fire = touchui.get_child( 1 )
	
	if touch_fire:
		touch_fire.button_down.connect( fire_pressed )
		touch_fire.button_up.connect( fire_released )
	if touch_move:
		touch_move.value.connect( move_touch )

func fire_pressed():
	EnhancedInput.inject( ia_fire, true )
func fire_released():
	EnhancedInput.inject( ia_fire, false )

func move_touch( value:Vector2 ):
	EnhancedInput.inject( ia_move, -value )

func fire( _value ):
	tree.execute( owner, &"trigger", [])
	
func move( _value ):
	var calc:float = player.global_position.x + speed * _value * player.get_physics_process_delta_time() * move_scale
	if calc > 10 and calc < 640:
		player.global_position.x = calc
