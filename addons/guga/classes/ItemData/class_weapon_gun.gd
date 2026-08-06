class_name WeaponGunData extends WeaponData

@export_group( "Technical properties")
@export var magazine_size:int = 30
@export var burst_length:int = 3
@export var shoot_delay:float = 0.1
@export var reload_time:float = 2.0
@export var effective_range:int = 300
@export var damage:float = 5.0

@export_group("SFX")
@export var sfx_shoot:SFXPack
@export var sfx_reload:Array[ AudioStreamWAV ]