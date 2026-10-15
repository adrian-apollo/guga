class_name CHealth
extends ComponentBase

@export_range(0, 1000, 1, "or_greater", "hide_control") var max_health:float
@export_range(0, 1000, 1, "or_greater","hide_control") var initial_health:float
signal s_health_reduced( value:float )
signal s_health_restored( value:float )
signal s_health_changed( value:float )

var health:float

func event_begin():
	if initial_health > max_health:
		initial_health = max_health

	health = initial_health

func decrease_health( value:float ):
	health -= value
	s_health_changed.emit( health )
	s_health_reduced.emit( health )

func restore_health( value:float ):
	health += value
	s_health_changed.emit( health )
	s_health_restored.emit( health )
