class_name BetterJoystick extends VirtualJoystick

##	emitted with a value representing the stick position relative to the center
##	value between -1 and 1
##	Example: $BetterJoystick.value.connect( func( v ): player.velocity = v * 300.0 )
signal value( stick: Vector2 )

##	for tracking activity on the joystick
var b_is_pressed:bool = false
##	value of the finger moving trough the joystick, updated on process
##	(screen / viewport coordinates)
var touch_position:Vector2 = Vector2.ZERO

var _center:Vector2 = Vector2.ZERO	# stick center, screen coordinates
var _has_center:bool = false		# DYNAMIC / FOLLOWING: center = first finger position

func _ready():
	pressed.connect( is_pressed )
	released.connect( is_relesed )

func _process( _delta: float ):
	if !b_is_pressed:
		return

	#	when pressedd tracks finger position
	#	calcuated stick relative position here based on finger position
	#	emit signal with value
	touch_position = get_viewport().get_mouse_position()
	_update_center()
	var radius := _get_clamp_radius()
	var offset := touch_position - _center
	if joystick_mode == JOYSTICK_FOLLOWING:
		_center += offset - offset.limit_length( radius )	# base drags along
		offset = touch_position - _center
	value.emit( ( offset / radius ).limit_length( 1.0 ) )

func is_pressed():
	b_is_pressed = true
	_has_center = false

func is_relesed( _input_vector: Vector2 = Vector2.ZERO ):
	b_is_pressed = false
	touch_position = Vector2.ZERO
	value.emit( Vector2.ZERO )

##	FIXED: node position on screen. Others: where the finger first landed.
func _update_center():
	if joystick_mode == JOYSTICK_FIXED:
		_center = get_global_transform_with_canvas() * ( size * initial_offset_ratio )
	elif !_has_center:
		_center = touch_position
		_has_center = true

##	Screen distance from the center that counts as full deflection (value length = 1)
func _get_clamp_radius() -> float:
	var screen_scale := get_global_transform_with_canvas().get_scale().x
	return maxf( joystick_size * 0.5 * clampzone_ratio * screen_scale, 1.0 )
