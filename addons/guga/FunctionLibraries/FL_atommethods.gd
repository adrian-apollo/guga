class_name AtomMethods

static func raycastfromposition(
	node:Node,
	distance:int,
	debug:bool,
	color:Color,
	duration:float,
	radius,
	varmin:float,
	varmax:float ) -> Dictionary:

	var worldspace = node.get_world_3d().direct_space_state

	var mousepos = node.get_viewport().get_mouse_position()
	var start:Vector3 = node.get_viewport().get_camera_3d().project_ray_origin( mousepos )
	var end:Vector3 = node.get_viewport().get_camera_3d().project_position( mousepos, distance)
	#rand offset end
	end.x += randf_range( varmin, varmax )
	end.y += randf_range( varmin, varmax )

	var result:Dictionary = worldspace.intersect_ray(
		PhysicsRayQueryParameters3D.create( start, end )
		)

	if result and debug:
		DebugDraw3D.draw_sphere(result.position, radius, color, duration)

	return result

static func _raycastfromcameracenter(
	node:Node,
	distance:int,
	debug:bool,
	radius:float,
	color:Color,
	duration:float ) -> Dictionary:
	var worldspace = node.get_world_3d().direct_space_state

	var mouseposition:Vector2 = node.get_viewport().get_window().get_size() / 2.0

	var start:Vector3 = node.get_viewport().get_camera_3d().project_ray_origin( mouseposition )
	var end:Vector3 = node.get_viewport().get_camera_3d().project_position( mouseposition, distance)

	var result:Dictionary = worldspace.intersect_ray(
		 PhysicsRayQueryParameters3D.create( start, end )
		 )

	if result and debug:
		DebugDraw3D.draw_sphere(result.position, radius, color, duration)

	return result

static func _createtimerbycallable(
	owner:Node,
	callable:Callable,
	value:float = 1,
	repeat:bool = true ) -> Timer:

	var timer:Timer = Timer.new()
	owner.add_child( timer )
	timer.owner = owner
	timer.start( value )
	timer.set_autostart( repeat )
	timer.connect("timeout", callable)

	return timer

static func _test() -> void:
	print("Atom_Methods OK")

static func macro_getchildfrompath(owner:Node, path:NodePath) -> Node:
	return owner.find_child( path.get_name( path.get_name_count() - 1 ) )

static func macro_printmsg( text ):
	MailServer.sendmessage.emit(
		UIManager.find_child("debugdata",
		true),
		"adddebugnotification",
		[ str ( text ) ]
		)
