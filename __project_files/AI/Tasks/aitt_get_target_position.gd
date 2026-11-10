class_name AITTGetTargetPosition extends AITaskBase

@export var source_parameter:StringName
@export var output_parameter:StringName

func enter( _aitree: AITreeBase ):
	var actor:Node2D = _aitree.parameters[ source_parameter ]
	
	_aitree.const_parameters[ output_parameter ] = actor.global_position
	finish_task( _aitree )