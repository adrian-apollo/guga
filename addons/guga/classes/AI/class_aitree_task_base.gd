@abstract
class_name AITTaskBase
extends RefCounted

enum result {
	SUCCESS,
	FAIL
}

func enter():
	pass

func update():
	pass

func exit() -> result:
	return result.SUCCESS
