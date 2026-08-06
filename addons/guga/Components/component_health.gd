extends ComponentBase
class_name CHealth

@export_group("Health")
@export_range(0, 100, 1, "or_greater" ) var max_health:float = 100
@export_range(0, 100, 1, "or_greater" ) var initial_health:float = 100

var currenthealth:float

func _begin( ) -> void:
	currenthealth = initial_health

#region component methods
func resethealth() -> void:
	currenthealth = max_health

func takedamage( amount:float ) -> float:
	if currenthealth > 0:
			currenthealth -= amount
			if currenthealth < 0:
				currenthealth = 0
	return currenthealth

func gethealth( actor:Node ) -> void:
	MailServer.sendmessage.emit(actor, "_receivedata", [currenthealth] )

#endregion
