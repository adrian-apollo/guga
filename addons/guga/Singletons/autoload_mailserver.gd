extends Node

#region signals

signal sendmessage(receiver:Node, methodname:String, args:Array)

#region

func send_message(receiver:Node, methodname:String, args:Array):
	sendmessage.emit(receiver, methodname, args)

#endregion
