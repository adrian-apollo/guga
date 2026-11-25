class_name GameplayStatics
extends RefCounted
#region 1. ACCESO A FRAMEWORK Y JUGADORES (GameMode, GameState, Controllers, Pawns)
# ==============================================================================

## Equivalente a: UGameplayStatics::GetPlayerController(const UObject* WorldContextObject, int32 PlayerIndex)
static func get_player_controller(_world_context: Node, _player_index: int = 0) -> Node:
	# Esqueleto: obtener el árbol de escenas, acceder al grupo "player_controllers" o manager y devolver el índice pedido.
	return null

## Equivalente a: UGameplayStatics::GetPlayerPawn(const UObject* WorldContextObject, int32 PlayerIndex)
static func get_player_pawn(_world_context: Node, _player_index: int = 0) -> Node:
	# Esqueleto: obtener el CharacterBody2D / CharacterBody3D controlado por el PlayerController correspondiente.
	return null

## Equivalente a: UGameplayStatics::GetPlayerCharacter(const UObject* WorldContextObject, int32 PlayerIndex)
static func get_player_character(_world_context: Node, _player_index: int = 0) -> CharacterBody3D:
	# Esqueleto: homólogo directo casteado a Character 3D.
	return null

## Equivalente a: UGameplayStatics::GetPlayerCameraManager(const UObject* WorldContextObject, int32 PlayerIndex)
static func get_player_camera_manager(_world_context: Node, _player_index: int = 0) -> Node:
	# Esqueleto: devolver el nodo/clase que administra límites, shakes, y blend de la cámara del jugador.
	return null

## Equivalente a: UGameplayStatics::GetGameMode(const UObject* WorldContextObject)
static func get_game_mode(_world_context: Node) -> Node:
	# Esqueleto: obtener la autoridad del juego (nodo raíz o singleton de GameMode).
	return null

## Equivalente a: UGameplayStatics::GetGameState(const UObject* WorldContextObject)
static func get_game_state(_world_context: Node) -> Node:
	# Esqueleto: obtener el estado replicado de la partida (puntuaciones, tiempo restante).
	return null

## Equivalente a: UGameplayStatics::GetGameInstance(const UObject* WorldContextObject)
static func get_game_instance(_world_context: Node) -> Node:
	# Esqueleto: en Godot equivale a un Autoload persistente que sobrevive entre cambios de escena.
	return null

#endregion

#region 2. GESTIÓN DE NIVELES Y TRANSICIONES (Level Streaming / World)
# ==============================================================================

## Equivalente a: UGameplayStatics::OpenLevel(const UObject* WorldContextObject, FName LevelName, ...)
static func open_level(_world_context: Node, _level_path: String, _absolute: bool = true, _options: String = "") -> void:
	# Esqueleto: cambiar de escena mediante get_tree().change_scene_to_file(_level_path).
	pass

## Equivalente a: UGameplayStatics::GetCurrentLevelName(const UObject* WorldContextObject, bool bRemovePrefixString)
static func get_current_level_name(_world_context: Node, _remove_prefix_string: bool = true) -> String:
	# Esqueleto: extraer el nombre del nodo raíz de la escena activa.
	return ""

## Equivalente a: UGameplayStatics::LoadStreamLevel(const UObject* WorldContextObject, FName LevelName, ...)
static func load_stream_level(_world_context: Node, _level_scene: PackedScene, _make_visible_after_load: bool = true) -> void:
	# Esqueleto: instanciar un subnivel de forma asíncrona y agregarlo como hijo del contenedor del mundo.
	pass

## Equivalente a: UGameplayStatics::UnloadStreamLevel(const UObject* WorldContextObject, FName LevelName, ...)
static func unload_stream_level(_world_context: Node, _level_node: Node) -> void:
	# Esqueleto: destruir o remover el subnivel instanciado (queue_free).
	pass

#endregion

#region 3. SPAWNING DE OBJETOS Y ACTORES
# ==============================================================================

## Equivalente a: UGameplayStatics::BeginDeferredActorSpawnFromClass(...)
## Instancia la escena pero NO la agrega al árbol todavía para poder inicializar variables.
static func begin_deferred_actor_spawn(_world_context: Node, _scene: PackedScene, _transform: Transform3D) -> Node:
	# Esqueleto: var actor = _scene.instantiate() y devolverlo antes de add_child().
	return null

## Equivalente a: UGameplayStatics::FinishSpawningActor(AActor* Actor, const FTransform& SpawnTransform)
static func finish_spawning_actor(_world_context: Node, _actor: Node, _transform: Transform3D) -> Node:
	# Esqueleto: aplicar transform y llamar a _world_context.add_child(_actor).
	return null

## Equivalente a: UGameplayStatics::SpawnObject(...)
static func spawn_object(_object_class: GDScript, _owner: RefCounted = null) -> RefCounted:
	# Esqueleto: instanciar un UObject / RefCounted que no está en el árbol de nodos.
	return null

#endregion

#region 4. AUDIO Y SONIDO (2D y 3D en el mundo)
# ==============================================================================

## Equivalente a: UGameplayStatics::PlaySound2D(...)
static func play_sound_2d(_world_context: Node, _sound: AudioStream, _volume_multiplier: float = 1.0, _pitch_multiplier: float = 1.0, _start_time: float = 0.0) -> void:
	# Esqueleto: crear un AudioStreamPlayer efímero en la raíz, reproducirlo y destruirlo con queue_free al terminar.
	pass

## Equivalente a: UGameplayStatics::PlaySoundAtLocation(...)
static func play_sound_at_location(_world_context: Node, _sound: AudioStream, _location: Vector3, _volume_multiplier: float = 1.0, _pitch_multiplier: float = 1.0) -> void:
	# Esqueleto: crear un AudioStreamPlayer3D en la coordenada global dada, reproducirlo y auto-destruirlo.
	pass

## Equivalente a: UGameplayStatics::SpawnSoundAtLocation(...)
## A diferencia de PlaySound, devuelve la referencia al reproductor para poder detenerlo o modularlo en tiempo real.
static func spawn_sound_at_location(_world_context: Node, _sound: AudioStream, _location: Vector3, _volume_multiplier: float = 1.0) -> AudioStreamPlayer3D:
	# Esqueleto: instanciar, configurar global_position, add_child y devolver la referencia viva.
	return null

## Equivalente a: UGameplayStatics::SpawnSoundAttached(...)
static func spawn_sound_attached(_sound: AudioStream, _attach_to_component: Node3D, _bus_name: StringName = &"Master") -> AudioStreamPlayer3D:
	# Esqueleto: agregar AudioStreamPlayer3D como hijo del nodo objetivo para que siga su movimiento.
	return null

#endregion

#region 5. EFECTOS VISUALES / PARTÍCULAS (Niagara / Cascade)
# ==============================================================================

## Equivalente a: UGameplayStatics::SpawnEmitterAtLocation(...)
static func spawn_emitter_at_location(_world_context: Node, _emitter_scene: PackedScene, _location: Vector3, _rotation: Vector3 = Vector3.ZERO, _auto_destroy: bool = true) -> GPUParticles3D:
	# Esqueleto: instanciar nodo de partículas (GPUParticles3D/CPUParticles3D), posicionar y activar emitting = true.
	return null

## Equivalente a: UGameplayStatics::SpawnEmitterAttached(...)
static func spawn_emitter_attached(_emitter_scene: PackedScene, _attach_to: Node3D, _relative_transform: Transform3D = Transform3D.IDENTITY) -> GPUParticles3D:
	# Esqueleto: emparentar el sistema de partículas a un hueso o nodo visual en movimiento.
	return null

#endregion

#region 6. SISTEMA DE DAÑO (Damage Framework)
# ==============================================================================

## Equivalente a: UGameplayStatics::ApplyDamage(AActor* DamagedActor, float BaseDamage, ...)
static func apply_damage(_damaged_node: Node, _base_damage: float, _event_instigator: Node, _damage_causer: Node, _damage_type_class: GDScript = null) -> float:
	# Esqueleto: verificar si el objetivo tiene método take_damage(), invocarlo y devolver el daño neto aplicado.
	return 0.0

## Equivalente a: UGameplayStatics::ApplyPointDamage(...)
static func apply_point_damage(_damaged_node: Node, _base_damage: float, _hit_from_direction: Vector3, _hit_info: Dictionary, _event_instigator: Node, _damage_causer: Node) -> float:
	# Esqueleto: daño directional de proyectil/bala con información de impacto (Raycast result).
	return 0.0

## Equivalente a: UGameplayStatics::ApplyRadialDamage(...)
static func apply_radial_damage(_world_context: Node, _base_damage: float, _origin: Vector3, _damage_radius: float, _damage_causer: Node, _ignore_actors: Array[Node] = [], _full_damage: bool = false) -> bool:
	# Esqueleto: hacer PhysicsShapeQuery3D (esfera), iterar cuerpos en radio, calcular atenuación por distancia y llamar apply_damage.
	return false

## Equivalente a: UGameplayStatics::ApplyRadialDamageWithFalloff(...)
static func apply_radial_damage_with_falloff(_world_context: Node, _base_damage: float, _minimum_damage: float, _origin: Vector3, _inner_radius: float, _outer_radius: float, _falloff_exponent: float = 1.0) -> bool:
	# Esqueleto: daño por explosión con radio interno (daño máximo) y caída gradual hasta el radio externo.
	return false

#endregion

#region 7. TIEMPO, PAUSA Y DILATACIÓN TEMPORAL (Time Dilation / Slomo)
# ==============================================================================

## Equivalente a: UGameplayStatics::SetGlobalTimeDilation(const UObject* WorldContextObject, float TimeDilation)
static func set_global_time_dilation(_world_context: Node, _time_dilation: float) -> void:
	# Esqueleto: Engine.time_scale = _time_dilation
	pass

## Equivalente a: UGameplayStatics::GetGlobalTimeDilation(const UObject* WorldContextObject)
static func get_global_time_dilation(_world_context: Node) -> float:
	# Esqueleto: return Engine.time_scale
	return 1.0

## Equivalente a: UGameplayStatics::SetGamePaused(const UObject* WorldContextObject, bool bPaused)
static func set_game_paused(_world_context: Node, _paused: bool) -> void:
	# Esqueleto: _world_context.get_tree().paused = _paused
	pass

## Equivalente a: UGameplayStatics::IsGamePaused(const UObject* WorldContextObject)
static func is_game_paused(_world_context: Node) -> bool:
	# Esqueleto: return _world_context.get_tree().paused
	return false

## Equivalente a: UGameplayStatics::GetWorldDeltaSeconds(const UObject* WorldContextObject)
static func get_world_delta_seconds(_world_context: Node) -> float:
	# Esqueleto: return _world_context.get_process_delta_time()
	return 0.0

## Equivalente a: UGameplayStatics::GetRealTimeSeconds(const UObject* WorldContextObject)
static func get_real_time_seconds(_world_context: Node) -> float:
	# Esqueleto: return Time.get_ticks_msec() / 1000.0
	return 0.0

#endregion

#region 8. BÚSQUEDA Y CONSULTAS DE ACTORES EN ESCENA
# ==============================================================================

## Equivalente a: UGameplayStatics::GetAllActorsOfClass(...)
static func get_all_actors_of_class(_world_context: Node, _class_type: GDScript) -> Array[Node]:
	# Esqueleto: recorrer el árbol recursivamente o filtrar grupos buscando nodos cuyo get_script() o 'is' coincida.
	return []

## Equivalente a: UGameplayStatics::GetAllActorsWithTag(...)
static func get_all_actors_with_tag(_world_context: Node, _tag: StringName) -> Array[Node]:
	# Esqueleto: return _world_context.get_tree().get_nodes_in_group(_tag)
	return []

## Equivalente a: UGameplayStatics::GetActorArrayBounds(...)
static func get_actor_array_bounds(_actors: Array[Node], _only_colliding_components: bool = false) -> AABB:
	# Esqueleto: calcular el bounding box acumulativo (AABB) de una lista de actores/nodos 3D.
	return AABB()

#endregion

#region 9. GUARDADO Y PERSISTENCIA (SaveGame Framework)
# ==============================================================================

## Equivalente a: UGameplayStatics::CreateSaveGameObject(TSubclassOf<USaveGame> SaveGameClass)
static func create_save_game_object(_save_game_script: GDScript) -> Resource:
	# Esqueleto: instanciar un Resource personalizado que herede de Resource.
	return null

## Equivalente a: UGameplayStatics::SaveGameToSlot(USaveGame* SaveGameObject, const FString& SlotName, ...)
static func save_game_to_slot(_save_object: Resource, _slot_name: String, _user_index: int = 0) -> bool:
	# Esqueleto: ResourceSaver.save(_save_object, "user://" + _slot_name + ".tres") == OK
	return false

## Equivalente a: UGameplayStatics::LoadGameFromSlot(const FString& SlotName, const int32 UserIndex)
static func load_game_from_slot(_slot_name: String, _user_index: int = 0) -> Resource:
	# Esqueleto: ResourceLoader.load("user://" + _slot_name + ".tres")
	return null

## Equivalente a: UGameplayStatics::DoesSaveGameExist(const FString& SlotName, const int32 UserIndex)
static func does_save_game_exist(_slot_name: String, _user_index: int = 0) -> bool:
	# Esqueleto: FileAccess.file_exists("user://" + _slot_name + ".tres")
	return false

## Equivalente a: UGameplayStatics::DeleteGameInSlot(const FString& SlotName, const int32 UserIndex)
static func delete_game_in_slot(_slot_name: String, _user_index: int = 0) -> bool:
	# Esqueleto: DirAccess.remove_absolute("user://" + _slot_name + ".tres") == OK
	return false

#endregion

#region 10. PROYECCIONES MATEMÁTICAS Y DE PANTALLA (Camera Viewport Math)

## Equivalente a: UGameplayStatics::ProjectWorldToScreen(...)
## Convierte coordenadas 3D del mundo en píxeles 2D de la pantalla.
static func project_world_to_screen(_camera: Camera3D, _world_position: Vector3) -> Vector2:
	# Esqueleto: return _camera.unproject_position(_world_position)
	return Vector2.ZERO

## Equivalente a: UGameplayStatics::DeprojectScreenToWorld(...)
## Convierte un píxel 2D del monitor en un origen y rayo de dirección 3D en el espacio del mundo.
static func deproject_screen_to_world(_camera: Camera3D, _screen_position: Vector2, _out_world_origin: Dictionary, _out_world_direction: Dictionary) -> bool:
	# Esqueleto: usar _camera.project_ray_origin y _camera.project_ray_normal
	return false

#endregion

#region 11. Registro de Actores y Componentes

#endregion

#region 12. Sistema de logging

const LOG_ROUTE:String = "user://logs/"

enum LogMessageMode{
	NORMAL,
	ERROR,
	WARNING
}

static func initialize_log_file( log_file:FileAccess, current_logfile_route:String ):
	var dir = DirAccess.open("user://")
	if !dir.dir_exists("logs"):
		dir.make_dir("logs")

	var datetime:Dictionary = Time.get_datetime_dict_from_system()
	var filename:String = "%04d_%02d_%02d_%02d_%02d_%02d.log" % [
			datetime.year, datetime.month, datetime.day,
			datetime.hour, datetime.minute, datetime.second
		]

	current_logfile_route = LOG_ROUTE + filename
	
	log_file = FileAccess.open(current_logfile_route, FileAccess.WRITE)
	
	if !log_file:
		push_error("GUGATree failed to create a log file")
		return
	
	GameplayStatics.new_log_message(
		Engine.get_main_loop(),
		"Log system ready",
		LogMessageMode.NORMAL
		)

static func new_log_message(sender:Object, message:String, mode:LogMessageMode):
	var tree:GugaTree = Engine.get_main_loop()
	if !is_instance_valid(sender):
		return
	if message.is_empty():
		return
	
	var currenttime:String = Time.get_time_string_from_system()
	var new_message:String = "%s [%s] %s  >>>  %s\n" % [
		LogMessageMode.find_key(mode),
		currenttime,
		sender,
		message
		]
	
	match mode:
		LogMessageMode.NORMAL:
			print(new_message.strip_edges())
		LogMessageMode.ERROR:
			push_error(new_message.strip_edges())
		LogMessageMode.WARNING:
			push_error(new_message.strip_edges())
	
	
	if tree.log_file:
		tree.log_file.store_string(new_message)
		tree.log_file.flush()

#endregion