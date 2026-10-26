class_name CLinearMovement extends ComponentBase

@export var speed:Vector2
@export var scale:float = 1

var node:Node2D

func event_begin():
	node = owner

func event_tick():
	node.global_position += speed * scale * owner.get_physics_process_delta_time()
