class_name CLevelController extends ComponentBase

var currentplayer:
	get():
		return currentplayer
	set(ref):
		currentplayer = ref

var level:Level

# signals
signal possesed( Node )
signal unpossesed( Node )

func _begin( ):
	level = tree.get_current_level()

#region possesion and unpossesion
func posses( pawn:Node ):
	if !is_instance_valid( pawn ):
		print("CLevelController >> " + "Possesion failed, empty pawn reference")
		return
	
	print("CLevelController >> Attempting to posses " + str( pawn.name ))
	tree.send_message(pawn, "_posses", [self])
	if !conector.datareceived == "OK":
		print("CLevelController >> Fail possesion of " + str( pawn.name ))
		return
	
	print("CLevelController >> SUCCESS ")
	possesed.emit( pawn )
	set( "currentplayer", pawn )

#	to complete
func unposses( pawn ):
	#tree.send_message(pawn, "_posses", [self])
	unpossesed.emit( pawn )

#endregion

func testcontroller():
	print(self)
