class_name CInteract extends ComponentBase

@export_category("Interact")
@export var can_interact:bool = true

func interact( actor:Node3D ) -> void:
	MailServer.sendmessage.emit(actor, "_tryinteract", [owner.data])
