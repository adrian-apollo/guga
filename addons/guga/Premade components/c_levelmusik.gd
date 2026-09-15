class_name CLevelMusik extends ComponentBase

@export_group("Music")
@export var music_pack:MusicPack
@export_range(0, 100, 1) var volume:float

var musicplayer:AudioStreamPlayer

# signals
signal trackstarted

func _begin( ) -> void:
	if music_pack:
		createaudiostreamplayer()
		playnexttrack()
		musicplayer.finished.connect(playnexttrack)

func createaudiostreamplayer() -> void:
	musicplayer = AudioStreamPlayer.new()
	musicplayer.bus = "Music"
	musicplayer.name = "MusicPlayer"
	owner.add_child(musicplayer)

func playnexttrack() -> void:
	musicplayer.stream = music_pack.tracks.pick_random()
	musicplayer.play()
	musicplayer.set_volume_linear( volume/100 )
	trackstarted.emit()
