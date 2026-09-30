extends Button

# Ruta de tu archivo .txt (asegúrate de que esté en res:// o en user://)
@export var file_path:String

@export var label_path:NodePath

var label_ref:Label
var tree:GugaTree

func _init() -> void:
	tree = Engine.get_main_loop()

# Esta función se ejecuta cuando apretas el botón
func _pressed():
	if file_path.is_empty():
		return
	label_ref = tree.get_node_from_nodepath( owner, label_path )
	if !is_instance_valid( label_ref ):
		return

	if FileAccess.file_exists( file_path ):
		var file = FileAccess.open( file_path, FileAccess.READ )
		if file:
			var content = file.get_as_text()
			label_ref.text = content
			file.close()
