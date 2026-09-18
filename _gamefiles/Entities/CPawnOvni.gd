class_name CPawnOvni extends CPawn

var charowner:CharacterBody2D
func event_possess():
	charowner = owner

func event_unposses():
	pass

func tick():
	if charowner.is_on_floor():
		charowner.velocity.y = -800
