class_name CPawnShip extends CPawn

@export_group( "Move config")
@export var move_scale:float = 1.0
@export var speed:float = 1.0

@export_group("Input")
@export var imc:InputMappingContext
@export var ia_fire:InputAction
@export var ia_move:InputAction
@export var debug_input:bool = false
@export var spawner_path:NodePath

var player:Node2D

var touchui:UIWidgetBase = load( "uid://fpr4sb12vrbi" ).instantiate()
var touch_move:BetterJoystick
var touch_fire:Button
var spawner2d:Spawner2D

func event_begin():
	player = owner
	tree.execute( owner, &"_activate_spawner", [])
	
	if !spawner_path.is_empty():
		spawner2d = tree.get_node_from_nodepath( owner, spawner_path )

func event_physics_tick( delta:float ):
	var calc:float = player.global_position.x + speed * ia_move.value * delta * move_scale
	if calc > 10 and calc < 640:
		player.global_position.x = calc

func event_possessed( _controller ) -> bool:
	controller = _controller
	tocuh_input()
	EnhancedInput.add_context( imc )
	EnhancedInput.debug_overlay = debug_input

	ia_fire.triggered.connect( fire )
	return true

func event_unpossessed( _controller ) -> bool:
	EnhancedInput.remove_context( imc )
	touchui.queue_free()
	return true

func tocuh_input():
	if !OS.has_feature("mobile"):
		return
	tree.current_level._ui.add_widget_to_layer( touchui, &"gameplay_menus" )
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
	if spawner2d:
		spawner2d.trigger()
