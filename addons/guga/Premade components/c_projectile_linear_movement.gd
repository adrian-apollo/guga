extends ComponentBase
class_name CPorjectileLinearMovement

@export var direction:Vector2 = Vector2(0,0)

var ownerref:Node2D

func begin( ):
	ownerref = owner

func tick() -> void:
	ownerref.position += direction
