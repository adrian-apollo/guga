extends Node
## Runtime manager (autoload "EnhancedInput"). Routes input events to the players and runs
## their updates. Player 0 is the default player: add_context(), remove_context(), clear_contexts(),
## has_context() and inject() here are shortcuts for get_player(). See InputPlayer.

## A gamepad was plugged in. `device` is its joypad id (use it in create_player()).
signal joypad_connected(device: int)

##	A gamepad was removed. Its held buttons are released first.
##	Players that used `device` keep existing: remove them if you want.
signal joypad_disconnected(device: int)

signal s_update_player_inputs( delta:float )

enum UpdateMode {
	PROCESS,
	PHYSICS
}

## Callback where actions are evaluated and their signals emitted.
## Example: EnhancedInput.update_mode = EnhancedInput.UpdateMode.PHYSICS
var update_mode :UpdateMode = UpdateMode.PROCESS:
	set(v):
		update_mode = v
		_apply_update_mode()

## If true (default) actions keep updating while the tree is paused.
## Example: EnhancedInput.run_when_paused = false
var run_when_paused :bool = true:
	set(v):
		run_when_paused = v
		_apply_pause_mode()

## If true (default), key presses are ignored while an editable LineEdit/TextEdit has focus.
## Key releases still pass, so keys cannot get stuck. Mouse, gamepad and touch are not affected.
## Example: EnhancedInput.block_when_typing = false
var block_when_typing :bool = true

## Shows live debug text (players, contexts, actions with value and state, pointer positions).
## Example: EnhancedInput.debug_overlay = true
var debug_overlay :bool = false:
	set(v):
		debug_overlay = v
		_apply_debug_overlay()

## Key that toggles debug_overlay. KEY_NONE (default) = no key.
## Example: EnhancedInput.debug_toggle_key = KEY_F3
var debug_toggle_key: Key = KEY_NONE

## If true, the overlay hides actions that are idle (state NONE and value zero).
var debug_only_active :bool = false

## All local players. players[0] is the default one (any gamepad + keyboard + mouse + touch).
var players: Array[InputPlayer] = []

## touch finger index -> last position, only while the finger is down
var _finger_pos: Dictionary[int, Vector2] = {}
var _overlay: InputDebugOverlay

func _ready():
	_apply_pause_mode()
	_apply_update_mode()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _on_joy_connection_changed(device: int, connected: bool):
	if connected:
		joypad_connected.emit(device)
	else:
		for p: InputPlayer in players:
			p.release_device(device)  # no stuck buttons
		joypad_disconnected.emit(device)

func _apply_pause_mode():
	process_mode = Node.PROCESS_MODE_ALWAYS if run_when_paused else Node.PROCESS_MODE_PAUSABLE

func _apply_debug_overlay():
	if debug_overlay and _overlay == null:
		_overlay = InputDebugOverlay.new()
		add_child(_overlay)
	if _overlay:
		_overlay.visible = debug_overlay

func _apply_update_mode():
	set_process(update_mode == UpdateMode.PROCESS)
	set_physics_process(update_mode == UpdateMode.PHYSICS)

#region ---------- Players ----------

## Position in `players`. 0 = default player. Returns null if it does not exist.
func get_player(index :int = 0) -> InputPlayer:
	return players[index] if index >= 0 and index < players.size() else null

## New local player. device: joypad id (-1 any, InputPlayer.NO_JOYPAD none).
## Example: EnhancedInput.create_player(1)  # gamepad id 1
func create_player(device :int = -1, use_keyboard_mouse := false) -> InputPlayer:
	var p :InputPlayer = InputPlayer.new()
	p.device = device
	p.use_keyboard_mouse = use_keyboard_mouse
	players.append(p)
	s_update_player_inputs.connect( p.update )
	return p

func spawn_default_local_player_input() -> InputPlayer:
	var default_player:InputPlayer = InputPlayer.new( true )
	default_player.use_keyboard_mouse = true
	players.append( default_player )
	return default_player

## Removes a player (the default player cannot be removed). Indices of later players shift down.
func remove_player( player: InputPlayer ):
	if !player:
		return
	s_update_player_inputs.disconnect( player.update )
	player.clear_contexts()
	players.erase(player)

#endregion

# ---------- Pointer position ----------

## Current screen position in viewport pixels.
## finger = -1 (default): mouse;finger >= 0: touch index.
## A finger that is not down returns Vector2.ZERO: check is_finger_down() first.
## Works without contexts or mappings. Example: EnhancedInput.get_pointer_position(1)
func get_pointer_position(finger :int = -1) -> Vector2:
	if finger < 0:
		return get_viewport().get_mouse_position()
	return _finger_pos.get(finger, Vector2.ZERO)

func is_finger_down(finger: int) -> bool:
	return _finger_pos.has(finger)

# ---------- Events and update ----------

func _is_typing() -> bool:
	var f :Control = get_viewport().gui_get_focus_owner()
	if f is LineEdit:
		return (f as LineEdit).editable
	if f is TextEdit:
		return (f as TextEdit).editable
	return false

func _input(event: InputEvent):
	if event.is_echo():
		return
	if debug_toggle_key != KEY_NONE and event is InputEventKey and event.pressed and event.keycode == debug_toggle_key:

		debug_overlay = not debug_overlay
		return
	
	if block_when_typing and event is InputEventKey and event.is_pressed() and _is_typing():
		return

	var view_size :Vector2 = Vector2.ZERO  # only touch needs it
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		_track_finger(event)
		view_size = get_viewport().get_visible_rect().size
	
	for p: InputPlayer in players:
		if p.accepts(event) and p.handle_event(event, view_size):
			get_viewport().set_input_as_handled()  # a rebind capture consumed it
			break

func _track_finger(event: InputEvent):
	var touch := event as InputEventScreenTouch
	if touch != null:
		if not touch.pressed or touch.canceled:
			_finger_pos.erase(touch.index)
		else:
			_finger_pos[touch.index] = touch.position
	else:
		var drag := event as InputEventScreenDrag
		_finger_pos[drag.index] = drag.position

func _process(delta: float):
	_update(delta)

func _physics_process(delta: float):
	_update(delta)

func _update(delta: float):
	s_update_player_inputs.emit( delta )

	if debug_overlay and _overlay:
		_overlay.show_text(_debug_text())

func _debug_text() -> String:
	var blocks :PackedStringArray = PackedStringArray()
	for i in players.size():
		blocks.append(players[i].debug_text("Player %d" % i, debug_only_active))

	var mouse :Vector2 = get_pointer_position()
	var pointer :String = "[b]Pointer[/b] · mouse (%d, %d)" % [mouse.x, mouse.y]
	for id: int in _finger_pos:
		pointer += " · finger %d (%d, %d)" % [id, _finger_pos[id].x, _finger_pos[id].y]
	blocks.append(pointer)
	return "\n\n".join(blocks)
