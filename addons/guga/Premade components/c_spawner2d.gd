class_name CProjectileSpawner extends ComponentBase

@export var spawn_location:NodePath
@export var actors:Array[PackedScene]

var level:Level
var origin:Node2D

var wants_fire:bool

func begin( ):
	if level:
		level = tree.get_current_level()
	if !spawn_location.is_empty():
		origin = owner.find_child(spawn_location)

func tick():
	if wants_fire:
		print( " firing " )
	wants_fire = false

func spawn(scene:PackedScene, location2d:Vector2, amount:int, delay:float):
	pass

#	user side actions

func event_fire():
	wants_fire = true
