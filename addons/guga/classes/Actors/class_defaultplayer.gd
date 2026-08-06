extends Camera3D
class_name DefaultPlayer

################################################################################

func _ready() -> void:
	pass

################################################################################

func _onposses( _owner ) -> void:
	print("No player assigned to gamemode, assign one")
	
func _unposses( ) -> void:
	queue_free()

################################################################################
