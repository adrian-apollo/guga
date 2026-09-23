class_name CAISpawner extends ComponentBase

@export_range(0,100,1) var spawn_chance:int = 100

var randint:int

func tick():
	randint = randi_range(1,100)
	if randint <= spawn_chance:
		tree.send_message(
			owner,
			"event_fire",
			[]
		)
