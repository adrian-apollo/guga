#@abstract class_name Level_Manager 
extends Node

var currentlevel: Level
var savedlevels:Array[ Level ]
var loadinglevel: Level

# signals
signal levelchanged( Level )
signal levelloaded( Level )
signal leveldestroyed

#region public

func preloadlevel( _newlevel ) -> Level:
	print("LevelManager >> Preloading level start")

	var newlevel: Level

	if _newlevel is PackedScene:
		newlevel = _newlevel.instantiate()

	print("LevelManager >> Preloading level success")
	levelloaded.emit( newlevel )
	return newlevel

func changetolevel( newlevel: Level, freeprevious:bool ) -> Level:
	print("LevelManager >> Changing level")

	if currentlevel:
		remove_child( currentlevel )
		if freeprevious:
			destroylevel( currentlevel )
		else:
			savedlevels.append( currentlevel )
		currentlevel = null

	add_child( newlevel )
	currentlevel = newlevel
	currentlevel.owner = self
	levelchanged.emit( currentlevel )
	
	return newlevel

func getcurrentlevel() -> Level:
	return currentlevel

func destroylevel( level:Level):
	level.queue_free()
	leveldestroyed.emit()

#endregion