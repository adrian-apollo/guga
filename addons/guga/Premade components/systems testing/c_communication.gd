extends ComponentBase
class_name CDebugTest

@export var debugtext:String = "testing"

func begin( ) -> void:
	print( "debug component present ")
	
func tick() -> void:
	print( debugtext )
