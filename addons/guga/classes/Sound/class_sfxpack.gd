class_name SFXPack extends Resource
@export var tracks:Array[ AudioStreamWAV ]

var player:AudioStreamPlayer2D = AudioStreamPlayer2D.new()

func _init() -> void:
	set(&"resource_local_to_scene", true )

func play_random( actor:Node ):
	actor.add_child( player )
	player.owner = actor

	player.stream = tracks.pick_random()
	player.play()
