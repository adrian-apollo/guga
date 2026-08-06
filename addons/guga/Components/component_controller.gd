class_name CLevelController extends ComponentBase

var currentplayer:
	get():
		return currentplayer
	set(ref):
		currentplayer = ref

var level:Level

# signals
signal possesed( Node3D )
signal unpossesed( Node3D )

func _begin( ):
	level = LevelManager.getcurrentlevel()

#region

func testcontroller():
	print(self)

func posses( _pawn ):
	print("Controller >> Attempting to posses >> " + str( _pawn.name ))
	currentplayer = _pawn

	MailServer.sendmessage.emit(currentplayer, "_onposses", [])
	possesed.emit( currentplayer )

func unposses( _pawn ):
	currentplayer.call("_unposses")
	unpossesed.emit( _pawn )

#endregion