class_name CPawnOvni extends CPawn

@export var inputdata:InputDataContext

var charowner:CharacterBody2D

var player_wants_fly:bool = false

func event_possess():
	charowner = owner
	if inputdata:
		inputdata.enablemappingcontext()

func event_unposses():
	pass

func tick():
	if inputdata.inputactions[0].value_bool:
		player_wants_fly = true
	else:
		player_wants_fly = false

	move()

func move():
	if player_wants_fly:
		charowner.velocity.y -= 20
		if charowner.velocity.y < -250:
			charowner.velocity.y = -250
	
