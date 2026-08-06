class_name Dynamic_sun extends Node3D

#region entry data

@export_category( "Game day length")
@export_range(0, 24, 1) var game_hours:int = 24
@export_range(0, 60, 1) var game_minutes:int = 0
@export_range(0, 60, 1) var game_seconds:int = 0

@export_category( " Start time")
@export_range(0, 24, 1) var start_hour: int = 12
@export_range(0, 60, 1) var start_minute: int = 0
@export_range(0, 60, 1) var start_second: int = 0

@export_category("Sunlight colors")
@export var tipical_hue:Color = Color(0.851, 0.749, 0.49)
@export var afternoon_hue:Color = Color(0.808, 0.412, 0.263)

@export_category("Nodes")
@export var sun_center:Node3D
@export var sun:DirectionalLight3D

#region constants
const realsecondsinday:int = 86400

#region propterties
var gameseconds:int
var timescale:float
var currenttime:int

#region daystart

#region
func _ready() -> void:
	sun.set_color(tipical_hue)
	
	#calculate seconds of a day in game
	gameseconds = convertoseconds( game_hours, game_minutes, game_seconds )
	#calculate the time scale relative to real world
	timescale = 1 / ( float( realsecondsinday ) / float( gameseconds ) )

func _physics_process(delta: float) -> void:
	
	sun_center.rotate_z( deg_to_rad( 360 / ( float( realsecondsinday ) / ( float(realsecondsinday) / float(gameseconds) ) ) ) * delta  )

#endregion

#region
func convertoseconds( hour:int, minute:int, seconds:int ) -> int:
	var totalseconds:int = seconds + ( minute * 60 ) + ( hour * 3600 )
	return totalseconds
