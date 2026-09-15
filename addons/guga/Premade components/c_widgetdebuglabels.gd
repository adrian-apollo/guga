class_name CWidgetDebugLabels extends ComponentBase

@export var container_path:NodePath

var container:VBoxContainer
var labels:Array[Label]

func _begin( ):
	if container_path:
		container = AtomMethods.macro_getchildfrompath( owner, container_path )
	else:
		print(" Null container ")

func _tick():
	_removelabel()

func _removelabel():
	if labels.size() > 0:
		var label:Label = labels.get( 0 )
		if label:
			label.queue_free()
		labels.pop_front()

func adddebugnotification( text:String ):
	var newlabel:Label = Label.new()
	container.add_child( newlabel )
	newlabel.text = text
	newlabel.clip_text = true
	labels.append( newlabel )
