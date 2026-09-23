class_name CSpawner2D extends ComponentBase

@export var spawn_location:NodePath
@export var max_offset_x:float
@export var min_offset_x:float
@export var max_offset_y:float
@export var min_offset_y:float
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
	projectile.global_position.x += randf_range(min_offset_x, max_offset_x)
	projectile.global_position.y += randf_range(min_offset_y, max_offset_y)

#region	user side actions

func event_fire():
	wants_fire = true

#endregion
