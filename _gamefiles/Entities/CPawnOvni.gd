class_name CPawnOvni extends CPawn

@export var inputdata:InputDataContext

var charowner:CharacterBody2D
var touchlocation:Vector2

func event_possess():
	charowner = owner
	if inputdata:
		inputdata.enablemappingcontext()

func event_unposses():
	pass

func tick():
	charowner.move_and_slide()
	if !inputdata.inputactions[1].value_bool:
		touchlocation = Vector2(0.0, 0.0)
		return
	
	if touchlocation.length() == 0:
		touchlocation = DisplayServer.mouse_get_position()
	
	move()

func move():
	if touchlocation.y > charowner.position.y:
		charowner.velocity.y += 5
		
	if touchlocation.y < charowner.position.y:
		charowner.velocity.y -= 5
	
	
