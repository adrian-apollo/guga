extends Node
## Runtime manager (autoload "EnhancedInput"). Routes input events to the players and runs
## their updates. Player 0 is the default player: add_context(), remove_context(), clear_contexts(),
## has_context() and inject() here are shortcuts for get_player(). See InputPlayer.

## A gamepad was plugged in. `device` is its joypad id (use it in create_player()).
signal joypad_connected(device: int)
## A gamepad was removed. Its held buttons are released first. Players that used `device` keep existing: remove them if you want.
signal joypad_disconnected(device: int)

enum UpdateMode { PROCESS, PHYSICS }

## Callback where actions are evaluated and their signals emitted.
## Example: EnhancedInput.update_mode = EnhancedInput.UpdateMode.PHYSICS
var update_mode := UpdateMode.PROCESS:
	set(v):
		update_mode = v
		_apply_update_mode()

## If true (default) actions keep updating while the tree is paused.
## Example: EnhancedInput.run_when_paused = false
var run_when_paused := true:
	set(v):
		run_when_paused = v
		_apply_pause_mode()

## If true (default), key presses are ignored while an editable LineEdit/TextEdit has focus.
## Key releases still pass, so keys cannot get stuck. Mouse, gamepad and touch are not affected.
## Example: EnhancedInput.block_when_typing = false
var block_when_typing := true

## Shows live debug text (players, contexts, actions with value and state, pointer positions).
## Example: EnhancedInput.debug_overlay = true
var debug_overlay := false:
	set(v):
		debug_overlay = v
		_apply_debug_overlay()

## Key that toggles debug_overlay. KEY_NONE (default) = no key.
## Example: EnhancedInput.debug_toggle_key = KEY_F3
var debug_toggle_key: Key = KEY_NONE

## If true, the overlay hides actions that are idle (state NONE and value zero).
var debug_only_active := false

## All local players. players[0] is the default one (any gamepad + keyboard + mouse + touch).
var players: Array[InputPlayer] = []

var _finger_pos := {}  # touch finger index -> Vector2 (last position, only while the finger is down)
var _overlay: InputDebugOverlay


func _init() -> void:
	var default_player := InputPlayer.new(true)
	default_player.use_keyboard_mouse = true
	players.append(default_player)


func _ready() -> void:
	_apply_pause_mode()
	_apply_update_mode()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)


func _on_joy_connection_changed(device: int, connected: bool) -> void:
	if connected:
		joypad_connected.emit(device)
	else:
		for p in players:
			p.release_device(device)  # no stuck buttons
		joypad_disconnected.emit(device)


func _apply_pause_mode() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS if run_when_paused else Node.PROCESS_MODE_PAUSABLE


func _apply_debug_overlay() -> void:
	if debug_overlay and _overlay == null:
		_overlay = InputDebugOverlay.new()
		add_child(_overlay)
	if _overlay:
		_overlay.visible = debug_overlay


func _apply_update_mode() -> void:
	set_process(update_mode == UpdateMode.PROCESS)
	set_physics_process(update_mode == UpdateMode.PHYSICS)


# ---------- Players ----------

## Position in `players`. 0 = default player. Returns null if it does not exist.
func get_player(index := 0) -> InputPlayer:
	return players[index] if index >= 0 and index < players.size() else null


## New local player. device: joypad id (-1 any, InputPlayer.NO_JOYPAD none).
## Example: EnhancedInput.create_player(1)  # gamepad id 1
func create_player(device := -1, use_keyboard_mouse := false) -> InputPlayer:
	var p := InputPlayer.new()
	p.device = device
	p.use_keyboard_mouse = use_keyboard_mouse
	players.append(p)
	return p


## Removes a player (the default player cannot be removed). Indices of later players shift down.
func remove_player(player: InputPlayer) -> void:
	if player == players[0]:
		push_error("EnhancedInput.remove_player: the default player cannot be removed")
		return
	player.clear_contexts()
	players.erase(player)


# ---------- Default player shortcuts ----------

func add_context(context: InputMappingContext, priority := 0) -> void:
	players[0].add_context(context, priority)


func remove_context(context: InputMappingContext) -> void:
	players[0].remove_context(context)


func clear_contexts() -> void:
	players[0].clear_contexts()


func has_context(context: InputMappingContext) -> bool:
	return players[0].has_context(context)


func inject(action: InputAction, value: Variant = true) -> void:
	players[0].inject(action, value)


# ---------- Pointer position ----------

## Current screen position in viewport pixels. finger = -1 (default): mouse; finger >= 0: touch index.
## A finger that is not down returns Vector2.ZERO: check is_finger_down() first.
## Works without contexts or mappings. Example: EnhancedInput.get_pointer_position(1)
func get_pointer_position(finger := -1) -> Vector2:
	if finger < 0:
		return get_viewport().get_mouse_position()
	return _finger_pos.get(finger, Vector2.ZERO)


func is_finger_down(finger: int) -> bool:
	return _finger_pos.has(finger)


# ---------- Events and update ----------

func _is_typing() -> bool:
	var f := get_viewport().gui_get_focus_owner()
	if f is LineEdit:
		return (f as LineEdit).editable
	if f is TextEdit:
		return (f as TextEdit).editable
	return false


func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if debug_toggle_key != KEY_NONE and event is InputEventKey and event.pressed and event.keycode == debug_toggle_key:
		debug_overlay = not debug_overlay
		return
	if block_when_typing and event is InputEventKey and event.is_pressed() and _is_typing():
		return
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		_track_finger(event)
	var view_size := get_viewport().get_visible_rect().size
	for p in players:
		if p.accepts(event) and p.handle_event(event, view_size):
			get_viewport().set_input_as_handled()  # a rebind capture consumed it
			break


func _track_finger(event: InputEvent) -> void:
	if event is InputEventScreenTouch and (not event.pressed or event.canceled):
		_finger_pos.erase(event.index)
	else:
		_finger_pos[event.index] = event.position


func _process(delta: float) -> void:
	_update(delta)


func _physics_process(delta: float) -> void:
	_update(delta)


func _update(delta: float) -> void:
	for p in players.duplicate():  # callbacks may create/remove players
		p.update(delta)
	if debug_overlay and _overlay:
		_overlay.show_text(_debug_text())


func _debug_text() -> String:
	var blocks := PackedStringArray()
	for i in players.size():
		blocks.append(players[i].debug_text("Player %d" % i, debug_only_active))
	var mouse := get_pointer_position()
	var pointer := "[b]Pointer[/b] · mouse (%d, %d)" % [mouse.x, mouse.y]
	for id in _finger_pos:
		pointer += " · finger %d (%d, %d)" % [id, _finger_pos[id].x, _finger_pos[id].y]
	blocks.append(pointer)
	return "\n\n".join(blocks)
