class_name Connector extends RefCounted

var objrefs:Array[Object]
var tree:GugaTree
var datareceived

func _init() -> void:
	tree = ( Engine.get_main_loop() as GugaTree )

func setup_connector(objs:Array[Object]):
	if objs.size() == 0:
		return

	for oref:Object in objs:
		objrefs.push_back(oref)
	objrefs.push_back(self)
	
	call_deferred( "_connecttomailserver" )

func _connecttomailserver():
	tree.s_message.connect( _mailbox )

func _disconnect():
	disconnect("s_message", _mailbox)

func receivedata(data):
	datareceived = data
	call_deferred("_cleardatareceived")

func _cleardatareceived():
	datareceived = null

func _mailbox(_owner:Object, callable:String, args:Array):
	if objrefs.has(_owner):
		var executor:Object
		for obj:Object in objrefs:
			if obj.has_method( callable ):
				executor = obj
				break
				
		if !executor:
			return
			
		if args.size() == 1:
			executor.call(callable, args[0])
			return

		if args.size() > 1:
			executor.call(callable, args)
			return

		if args.is_empty():
			executor.call( callable )
			return

func free() -> void:
	_disconnect()
