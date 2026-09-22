class_name CProjectileSpawner extends ComponentBase

@export var spawn_location:NodePath
@export var actors:Array[PackedScene]

var level:Level
var origin:Node2D

var wants_fire:bool

func begin( ):
	level = tree.get_current_level()
	if !spawn_location.is_empty():
		origin = owner.find_child(spawn_location)

func tick():
	if wants_fire and actors.size() > 0:
		spawn(actors[0],origin.global_position)
	wants_fire = false

func spawn(scene:PackedScene, location2d:Vector2):
	var projectile:Node2D = scene.instantiate()
	level.add_child( projectile )
	projectile.owner = level
	projectile.global_position = location2d
	

#region	user side actions

func event_fire():
	wants_fire = true

#endregion
