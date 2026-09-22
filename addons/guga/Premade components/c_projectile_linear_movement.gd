extends ComponentBase
class_name CPorjectileLinearMovement

var ownerref:Node2D

func begin( ):
	ownerref = owner

func tick() -> void:
	ownerref.position.x += 5
	
