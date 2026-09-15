class_name CNearFrontScanner extends ComponentBase 

@export_group("Scanner")
@export var enabled:bool = true
@export var near_distance:float = 2
@export var far_distance:float = 50
@export var debug:bool = false

var near_found_data:Dictionary
var near_founded_actor:Node3D

var far_found_data:Dictionary
var far_found_actor:Node3D

func _tick() -> void:
	scan()

func scan( ) -> void:
	near_founded_actor = null
	far_found_actor = null
	near_found_data.clear()
	far_found_data.clear()

	if enabled:
		near_found_data = AtomMethods._raycastfromcameracenter(owner, near_distance, debug, 0.05, Color(0.217, 1.0, 0.0, 1.0), 0.01)
		far_found_data = AtomMethods._raycastfromcameracenter(owner, far_distance, debug, 0.05, Color(0.217, 1.0, 0.0, 1.0), 0.01)
		
		if near_found_data:
			near_founded_actor = near_found_data.get("collider")
		if far_found_data:
			far_found_actor = far_found_data.get("collider")

func getnearfrontactor( actor:Node ) -> void:
	MailServer.sendmessage.emit(actor, "_receivedata", [ near_founded_actor ] )

func getfaractor( actor:Node ) -> void:
	MailServer.sendmessage.emit(actor, "_receivedata", [ far_found_actor ] )

