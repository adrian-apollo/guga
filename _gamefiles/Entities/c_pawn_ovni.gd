class_name CPawnOvni extends CPawn

@export var inputdata:InputDataContext

var charowner:CharacterBody2D

#	input tracking
var player_wants_fly:bool = false

func event_possess():
	charowner = owner
	if inputdata:
		inputdata.enablemappingcontext()

func event_unposses():
	pass

func tick():
	#	move input detection
	if inputdata.inputactions[0].value_bool or inputdata.inputactions[2].value_bool:
		player_wants_fly = true
	else:
		player_wants_fly = false
	
	#	fire input detection
	if inputdata.inputactions[1].value_bool or inputdata.inputactions[3].value_bool:
		tree.send_message(owner, "event_fire", [])
	
	move()

func move():
	if player_wants_fly:
		charowner.velocity.y -= 20
		if charowner.velocity.y < -250:
			charowner.velocity.y = -250
