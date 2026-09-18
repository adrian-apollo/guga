extends ComponentBase
class_name CDebugCommunication

func begin( ) -> void:
	print( "debug component communincation present ")
	
	tree.send_message(owner, "test_execute_callable", [])
	tree.send_message(owner, "test_sum", [100,23])
	
	#	this test external data received on a connector
	tree.send_message(owner, "receivedata", ["success"])
	#	this prints success
	print( conector.datareceived )
	#	at next frame the data will be cleared
	await tree.create_timer(1,0,1,0).timeout
	#	this prints null
	print( conector.datareceived )
	
	#	lets find the amount of components theres in this object
	#	we call a method on the component manager with a reference to self
	#	so it knows who is calling and wants to receive the data
	tree.send_message(owner, "getamountcomponents", [self])
	print(conector.datareceived)

func test_execute_callable():
	print( "callable executed ")

func test_sum(data:Array):
	print( data[0] + data[1])
