class_name ActorStatic extends CSGMesh3D

@export var Components:ComponentsManager

#region

func _ready() -> void:
	if Components:
		Components.start( self )

#func _process(_delta: float) -> void:
	
#func _physics_process(_delta: float) -> void:

#endregion
