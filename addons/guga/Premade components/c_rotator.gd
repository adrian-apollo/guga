extends ComponentBase
class_name CRotator

@export var axe:Vector3
@export var speed:float

func _tick( ) -> void:
	if owner:
		owner.rotate_object_local( axe.normalized(), deg_to_rad( speed ) * owner.get_process_delta_time())
