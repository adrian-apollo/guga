extends ComponentBase
class_name CGravity

@export_group("Gravity")
@export var enabled:bool = true
@export_range(0, 1, 0.01, "or_greater" ) var gravity_scale:float = 1

@export_group("Movement")
@export var move_and_slide:bool = false

func tick() -> void:
	_applygravity()
	if move_and_slide:
		owner.move_and_slide()

#region component methods

func _applygravity() -> void:
	if owner.is_on_floor():
		owner.velocity.y = 0
		return
	if !enabled:
		return

	owner.velocity += owner.get_gravity() * gravity_scale * owner.get_physics_process_delta_time()

#endregion
