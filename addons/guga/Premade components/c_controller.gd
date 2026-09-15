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

#region

func testcontroller():
	print(self)

func posses( _pawn ):
	print("Controller >> Attempting to posses >> " + str( _pawn.name ))
	currentplayer = _pawn

	tree.send_message(currentplayer, "_onposses", [])
	possesed.emit( currentplayer )

func unposses( _pawn ):
	currentplayer.call("_unposses")
	unpossesed.emit( _pawn )

#endregion
