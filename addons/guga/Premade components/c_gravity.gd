extends ComponentBase
class_name CGravity

@export_group("Gravity")
@export var enabled:bool = true
@export_range(0, 100, 1, "or_greater" ) var gravity:float = 9.8

func _tick() -> void:
	_applygravity()
	owner.move_and_slide()

#region component methods

func _applygravity() -> void:
	if not owner.is_on_floor() and enabled:
		owner.velocity += owner.get_gravity() * owner.get_physics_process_delta_time()

#endregion
