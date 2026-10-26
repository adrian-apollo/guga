class_name InputPlayer
extends RefCounted
## One local player: own contexts, own device filter and own action instances, so several
## players can share the same .tres resources. Create with EnhancedInput.create_player().
## EnhancedInput.get_player() is the default player (the one the old EnhancedInput.add_context() uses).

## Emitted when start_rebind() captured an event and applied it.
signal rebind_finished(mapping_name: StringName, event: InputEvent)
## Emitted when start_rebind() was canceled (cancel_key or cancel_rebind()).
signal rebind_canceled(mapping_name: StringName)

## Emitted instead of rebind_finished when the captured event is already used by other named
## mappings of this player. `conflicts` = their names. Answer with resolve_rebind().
signal rebind_conflict(mapping_name: StringName, event: InputEvent, conflicts: Array)

## What to do with a conflict (see resolve_rebind):
## SWAP: the conflicting mappings get the old event of the mapping being rebound.
## REPLACE: the conflicting mappings are left unbound. KEEP_BOTH: both use the key. CANCEL: nothing changes.
enum ConflictChoice { SWAP, REPLACE, KEEP_BOTH, CANCEL }

## device = NO_JOYPAD: ignore all gamepads.
const NO_JOYPAD := -2

const _STATE_COLORS := ["#888888", "#ffcc00", "#44dd66"]  # NONE, ONGOING, TRIGGERED

## Joypad id this player listens to. -1 = any joypad, NO_JOYPAD = none.
var device := -1
## If true, keyboard, mouse and touch events also reach this player.
var use_keyboard_mouse := false
## Key that cancels start_rebind(). KEY_NONE = nothing cancels (Escape can then be bound).
var cancel_key: Key = KEY_ESCAPE

var _originals: bool      # default player returns the original InputAction resources
var _contexts := []       # [{context, priority}] sorted by priority, highest first
var _raw := {}            # InputMapping -> Vector3 (mouse/touch drag accumulate until the next update)
var _raw_device := {}     # InputMapping -> joypad id that wrote its last raw value (see release_device)
var _last := {}           # InputMapping -> Vector3 (value of previous frame)
var _memory := {}         # InputMapping -> Dictionary (state of its triggers/modifiers, plus "player" id)
var _instances := {}      # InputAction -> InputAction (this player's copy)
var _injected := {}       # InputAction -> Vector3 (see inject)
var _injected_maps := {}  # InputAction -> InputMapping (pseudo mapping that carries inject state)
var _finger_owner := {}   # touch finger index -> InputMapping that owns it
var _rebinds := {}        # mapping_name -> InputEvent (this player's key overrides)
var _capturing := &""     # mapping_name waiting for the next event (see start_rebind)
var _pending := {}        # {name, event, conflicts} waiting for resolve_rebind


func _init(use_originals := false) -> void:
	_originals = use_originals


## This player's own copy of `action` (value, state and signals are private to this player).
## The default player returns the original resource.
func get_action(action: InputAction) -> InputAction:
	if not _instances.has(action):
		_instances[action] = action if _originals else action.duplicate() as InputAction
	return _instances[action]


func add_context(context: InputMappingContext, priority := 0) -> void:
	remove_context(context)
	_contexts.append({"context": context, "priority": priority})
	_contexts.sort_custom(func(a, b): return a.priority > b.priority)
	for m in context.mappings:
		if m.action:
			get_action(m.action)


func remove_context(context: InputMappingContext) -> void:
	_contexts = _contexts.filter(func(e): return e.context != context)
	for idx in _finger_owner.keys():
		if context.mappings.has(_finger_owner[idx]):
			_finger_owner.erase(idx)
	for m in context.mappings:
		_raw.erase(m)
		_raw_device.erase(m)
		_last.erase(m)
		_memory.erase(m)


func clear_contexts() -> void:
	for e in _contexts.duplicate():
		remove_context(e.context)


func has_context(context: InputMappingContext) -> bool:
	return _contexts.any(func(e): return e.context == context)


## Feeds a value into an action of this player from code (virtual buttons, on-screen joysticks...).
## The value stays until you inject again: inject(jump, true) = pressed, inject(jump, false) = released.
## It goes through the action's own modifiers/triggers (not mapping-level ones) and is summed
## with values coming from mappings. Works without an active context.
## value: bool, int/float, Vector2 or Vector3.
func inject(action: InputAction, value: Variant = true) -> void:
	_injected[action] = _to_vec3(value)
	get_action(action)
	if not _injected_maps.has(action):
		var m := InputMapping.new()
		m.action = action
		_injected_maps[action] = m


func _to_vec3(v: Variant) -> Vector3:
	match typeof(v):
		TYPE_BOOL: return Vector3(1.0 if v else 0.0, 0.0, 0.0)
		TYPE_INT, TYPE_FLOAT: return Vector3(float(v), 0.0, 0.0)
		TYPE_VECTOR2: return Vector3(v.x, v.y, 0.0)
		TYPE_VECTOR3: return v
	push_error("InputPlayer.inject: unsupported value type")
	return Vector3.ZERO


## Device filter: joypad events must come from `device`; everything else needs use_keyboard_mouse.
func accepts(event: InputEvent) -> bool:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		return device == -1 or event.device == device
	return use_keyboard_mouse


## Stores the raw value of `event` for every matching mapping. Called by EnhancedInput.
## Returns true if the event was consumed by a rebind capture (EnhancedInput marks it as handled).
func handle_event(event: InputEvent, view_size: Vector2) -> bool:
	if _capturing != &"" and _try_capture(event):
		return true
	if event is InputEventScreenDrag or event is InputEventScreenTouch:
		_read_touch(event, view_size)
		return false
	for entry in _contexts:
		for m: InputMapping in entry.context.mappings:
			var bound := _event_of(m)
			if bound == null:
				continue
			var v: Variant = _read(bound, event)
			if v == null:
				continue
			if bound is InputEventMouseMotion:
				_raw[m] = _raw.get(m, Vector3.ZERO) + v  # several motions per frame add up
			else:
				_raw[m] = v
			if event is InputEventJoypadButton or event is InputEventJoypadMotion:
				_raw_device[m] = event.device
	return false


# ---------- Rebinding ----------

## The event a mapping listens to for this player: its rebind (by mapping_name) or its own event.
func _event_of(m: InputMapping) -> InputEvent:
	if m.mapping_name != &"" and _rebinds.has(m.mapping_name):
		return _rebinds[m.mapping_name]
	return m.event


## Makes every mapping named `mapping_name` listen to `event` (this player only). No conflict check
## (see find_conflicts / start_rebind).
## Supported: key, mouse button, joypad button, joypad axis. Keys are matched by physical position.
## Example: player.rebind(&"jump_key", event_k)
func rebind(mapping_name: StringName, event: InputEvent) -> void:
	if mapping_name == &"" or _serialize(event).is_empty():
		push_error("InputPlayer.rebind: needs a mapping_name and a key, mouse button, joypad button or joypad axis event")
		return
	_rebinds[mapping_name] = event
	_release_named(mapping_name)


## Leaves the named mappings without any input for this player (until reset_binding).
func unbind(mapping_name: StringName) -> void:
	_rebinds[mapping_name] = null
	_release_named(mapping_name)


## Back to the event the mapping has in its resource.
func reset_binding(mapping_name: StringName) -> void:
	_rebinds.erase(mapping_name)
	_release_named(mapping_name)


func reset_all_bindings() -> void:
	for n in _rebinds.keys():
		reset_binding(n)


## Current event of a named mapping (rebind or original), null if unknown.
func get_binding(mapping_name: StringName) -> InputEvent:
	if _rebinds.has(mapping_name):
		return _rebinds[mapping_name]
	for entry in _contexts:
		for m: InputMapping in entry.context.mappings:
			if m.mapping_name == mapping_name:
				return m.event
	return null


## Waits for the player's next key, mouse button, joypad button or joypad axis (>= 0.5) and rebinds
## `mapping_name` to it. That event is consumed. Ends with rebind_finished, or rebind_canceled (cancel_key).
func start_rebind(mapping_name: StringName) -> void:
	cancel_rebind()
	_capturing = mapping_name


func cancel_rebind() -> void:
	var n := _capturing
	if n == &"" and not _pending.is_empty():
		n = _pending.name
	_capturing = &""
	_pending = {}
	if n != &"":
		rebind_canceled.emit(n)


## True while start_rebind() is waiting for an event.
func is_rebinding() -> bool:
	return _capturing != &""


## True after rebind_conflict, until resolve_rebind() or cancel_rebind().
func has_pending_conflict() -> bool:
	return not _pending.is_empty()


## Names of the other mappings (in the contexts added to this player) that already use `event`.
## Example: player.find_conflicts(&"jump_key", event_k)
func find_conflicts(mapping_name: StringName, event: InputEvent) -> Array[StringName]:
	var out: Array[StringName] = []
	for entry in _contexts:
		for m: InputMapping in entry.context.mappings:
			var n := m.mapping_name
			if n != &"" and n != mapping_name and not out.has(n) and _same_input(_event_of(m), event):
				out.append(n)
	return out


## Answers rebind_conflict. SWAP / REPLACE / KEEP_BOTH apply the new event and then emit rebind_finished.
## CANCEL emits rebind_canceled.
func resolve_rebind(choice: ConflictChoice) -> void:
	if _pending.is_empty():
		return
	var pending := _pending
	_pending = {}
	var n: StringName = pending.name
	var e: InputEvent = pending.event
	if choice == ConflictChoice.CANCEL:
		rebind_canceled.emit(n)
		return
	var old := get_binding(n)  # before rebinding: SWAP hands it to the others
	for c in pending.conflicts:
		if choice == ConflictChoice.KEEP_BOTH:
			break
		if choice == ConflictChoice.SWAP and old != null and not _serialize(old).is_empty():
			rebind(c, old)
		else:
			unbind(c)
	rebind(n, e)
	rebind_finished.emit(n, e)


## Readable label for UI: InputPlayer.event_text(player.get_binding(&"jump_key")) -> "Space".
static func event_text(event: InputEvent) -> String:
	if event == null:
		return ""
	if event is InputEventKey and event.keycode == KEY_NONE:
		return OS.get_keycode_string(DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode))
	return event.as_text()


## Saves this player's rebinds to a ConfigFile. Returns an Error (OK on success).
## Example: player.save_bindings("user://p1_bindings.cfg")
func save_bindings(path: String) -> Error:
	var cfg := ConfigFile.new()
	for n in _rebinds:
		var e: InputEvent = _rebinds[n]
		cfg.set_value("bindings", str(n), {"type": "none"} if e == null else _serialize(e))
	return cfg.save(path)


## Replaces this player's rebinds with the ones in the file. Returns ERR_FILE_NOT_FOUND if there is none yet
## (normal on the first run: ignore it).
func load_bindings(path: String) -> Error:
	var cfg := ConfigFile.new()
	var err := cfg.load(path)
	if err != OK:
		return err
	reset_all_bindings()
	for n in cfg.get_section_keys("bindings"):
		var d: Dictionary = cfg.get_value("bindings", n, {})
		if d.get("type", "") == "none":
			unbind(StringName(n))
		else:
			var e := _deserialize(d)
			if e:
				rebind(StringName(n), e)
	return OK


## Consumes the event if it can be bound (a press, or an axis pushed >= 0.5).
func _try_capture(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and cancel_key != KEY_NONE and event.keycode == cancel_key:
		cancel_rebind()
		return true
	var e: InputEvent = null
	if event is InputEventKey and event.pressed:
		e = InputEventKey.new()
		e.physical_keycode = event.physical_keycode
	elif event is InputEventMouseButton and event.pressed:
		e = InputEventMouseButton.new()
		e.button_index = event.button_index
	elif event is InputEventJoypadButton and event.pressed:
		e = InputEventJoypadButton.new()
		e.button_index = event.button_index
	elif event is InputEventJoypadMotion and absf(event.axis_value) >= 0.5:
		e = InputEventJoypadMotion.new()
		e.axis = event.axis
		e.axis_value = signf(event.axis_value)
	if e == null:
		return false  # releases, small axis values...: let them pass
	var n := _capturing
	_capturing = &""
	var conflicts := find_conflicts(n, e)
	if conflicts.is_empty():
		rebind(n, e)
		rebind_finished.emit(n, e)
	else:
		_pending = {"name": n, "event": e, "conflicts": conflicts}
		rebind_conflict.emit(n, e, conflicts)
	return true


## Same physical input? Keys compare by keycode (physical keys are converted), axes by axis and direction.
func _same_input(a: InputEvent, b: InputEvent) -> bool:
	if a == null or b == null:
		return false
	var da := _serialize(a)
	var db := _serialize(b)
	if da.is_empty() or da.type != db.get("type"):
		return false
	match da.type:
		"key": return _key_id(a) == _key_id(b)
		"joy_axis": return da.axis == db.axis and signf(da.axis_value) == signf(db.axis_value)
		_: return da.button_index == db.button_index


func _key_id(e: InputEvent) -> int:
	if e.keycode != KEY_NONE:
		return e.keycode
	return DisplayServer.keyboard_get_keycode_from_physical(e.physical_keycode)


func _serialize(e: InputEvent) -> Dictionary:
	if e is InputEventKey:
		return {"type": "key", "physical_keycode": e.physical_keycode, "keycode": e.keycode}
	if e is InputEventMouseButton:
		return {"type": "mouse_button", "button_index": e.button_index}
	if e is InputEventJoypadButton:
		return {"type": "joy_button", "button_index": e.button_index}
	if e is InputEventJoypadMotion:
		return {"type": "joy_axis", "axis": e.axis, "axis_value": e.axis_value}
	return {}


func _deserialize(d: Dictionary) -> InputEvent:
	match d.get("type", ""):
		"key":
			var e := InputEventKey.new()
			e.physical_keycode = int(d.get("physical_keycode", 0))
			e.keycode = int(d.get("keycode", 0))
			return e
		"mouse_button":
			var e := InputEventMouseButton.new()
			e.button_index = int(d.get("button_index", 0))
			return e
		"joy_button":
			var e := InputEventJoypadButton.new()
			e.button_index = int(d.get("button_index", 0))
			return e
		"joy_axis":
			var e := InputEventJoypadMotion.new()
			e.axis = int(d.get("axis", 0))
			e.axis_value = float(d.get("axis_value", 1.0))
			return e
	return null


## Zeroes the raw value of the mappings with this name, so nothing stays pressed after a rebind.
func _release_named(mapping_name: StringName) -> void:
	for entry in _contexts:
		for m: InputMapping in entry.context.mappings:
			if m.mapping_name == mapping_name:
				_raw[m] = Vector3.ZERO
				_raw_device.erase(m)


## Zeroes the raw value of every mapping last written by gamepad `id`.
## EnhancedInput calls it when a gamepad is unplugged, so held buttons do not stay pressed.
func release_device(id: int) -> void:
	for m in _raw_device.keys():
		if _raw_device[m] == id:
			_raw[m] = Vector3.ZERO
			_raw_device.erase(m)


## Raw value (Vector3) of `event` for the bound event, or null if it does not match.
func _read(bound: InputEvent, event: InputEvent) -> Variant:
	if bound is InputEventMouseMotion:
		if event is InputEventMouseMotion:
			return Vector3(event.relative.x, event.relative.y, 0.0)
		return null
	if bound is InputEventJoypadMotion:
		if event is InputEventJoypadMotion and event.axis == bound.axis:
			return Vector3(maxf(0.0, event.axis_value * signf(bound.axis_value)), 0.0, 0.0)
		return null
	if event.is_match(bound, false):
		return Vector3(1.0 if event.is_pressed() else 0.0, 0.0, 0.0)
	return null


## Touch: a finger belongs to the first mapping (context priority, then array order) whose
## touch_zone contains where it started. Bound InputEventScreenTouch = button (1 while the finger
## is down); bound InputEventScreenDrag = drag delta of that finger.
func _read_touch(event: InputEvent, view_size: Vector2) -> void:
	var idx: int = event.index
	if event is InputEventScreenTouch:
		var released: bool = not event.pressed or event.canceled
		if not released and not _finger_owner.has(idx):
			_claim_finger(idx, event.position / view_size)
		var m: InputMapping = _finger_owner.get(idx)
		if m == null:
			return
		if _event_of(m) is InputEventScreenTouch:
			_raw[m] = Vector3(0.0 if released else 1.0, 0.0, 0.0)
		if released:
			_finger_owner.erase(idx)
	else:
		var m: InputMapping = _finger_owner.get(idx)
		if m != null and _event_of(m) is InputEventScreenDrag:
			_raw[m] = _raw.get(m, Vector3.ZERO) + Vector3(event.relative.x, event.relative.y, 0.0)


func _claim_finger(idx: int, rel: Vector2) -> void:
	var taken := _finger_owner.values()
	for entry in _contexts:
		for m: InputMapping in entry.context.mappings:
			var e := _event_of(m)
			var touchy := e is InputEventScreenTouch or e is InputEventScreenDrag
			if touchy and m.touch_zone.has_point(rel) and not taken.has(m):
				_finger_owner[idx] = m
				return


## State Dictionary of a mapping. "player" is this player's instance id (triggers use it to
## find the right action instances, see InputTrigger._player_action).
func _mem(m: InputMapping) -> Dictionary:
	if not _memory.has(m):
		_memory[m] = {"player": get_instance_id()}
	return _memory[m]


## Evaluates modifiers, triggers, priority and consumption, then updates the action instances.
func update(delta: float) -> void:
	var values := {}    # InputAction -> Vector3
	var states := {}    # InputAction -> int
	var consumed := {}  # event text -> true (claimed by a higher priority context)
	for entry in _contexts:
		var claimed := []
		for m: InputMapping in entry.context.mappings:
			var e := _event_of(m)
			if m.action == null or e == null:
				continue
			var raw: Vector3 = _raw.get(m, Vector3.ZERO)
			if e is InputEventMouseMotion or e is InputEventScreenDrag:
				_raw[m] = Vector3.ZERO  # motion is a per-frame delta, consume it
			var mem := _mem(m)
			var value := m.apply_modifiers(raw, delta, mem)
			var state := m.evaluate(value, _last.get(m, Vector3.ZERO), delta, mem)
			_last[m] = value
			var key := e.as_text() + str(m.touch_zone)
			if consumed.has(key):
				continue
			values[m.action] = values.get(m.action, Vector3.ZERO) + value
			states[m.action] = maxi(states.get(m.action, 0), state)
			if raw.length() > 0.0 and m.action.consume_input:
				claimed.append(key)
		for key in claimed:
			consumed[key] = true
	for a in _injected:
		var m: InputMapping = _injected_maps[a]
		var mem := _mem(m)
		var value := m.apply_modifiers(_injected[a], delta, mem)
		var state := m.evaluate(value, _last.get(m, Vector3.ZERO), delta, mem)
		_last[m] = value
		values[a] = values.get(a, Vector3.ZERO) + value
		states[a] = maxi(states.get(a, 0), state)
	for a in _instances.keys():  # keys(): signal callbacks may add instances
		_instances[a].update(values.get(a, Vector3.ZERO), states.get(a, InputTrigger.State.NONE))


# ---------- Debug ----------

## BBCode with this player's contexts, actions (value, state) and rebind status.
## Used by the overlay (EnhancedInput.debug_overlay). only_active hides idle actions.
func debug_text(title: String, only_active := false) -> String:
	var pads := "any" if device == -1 else ("none" if device == NO_JOYPAD else str(device))
	var kbm := "keyboard/mouse" if use_keyboard_mouse else "no keyboard/mouse"
	var lines := PackedStringArray(["[b]%s[/b] · %s · pads: %s" % [title, kbm, pads]])
	var ctxs := PackedStringArray()
	for entry in _contexts:
		ctxs.append("%s (%d)" % [_res_name(entry.context), entry.priority])
	lines.append(" contexts: " + (", ".join(ctxs) if not ctxs.is_empty() else "none"))
	for a in _instances:
		var inst: InputAction = _instances[a]
		var state: int = inst.state
		if only_active and state == InputTrigger.State.NONE and not _is_active(inst.value):
			continue
		lines.append("  %s %s %s [color=%s]%s[/color]" % [
			_res_name(a).rpad(12), str(InputAction.ValueType.keys()[inst.value_type]).rpad(8),
			_fmt(inst.value).rpad(16), _STATE_COLORS[state], InputTrigger.State.keys()[state]])
	if _capturing != &"":
		lines.append(" [color=#ffcc00]rebind: press an input for '%s'[/color]" % _capturing)
	if not _pending.is_empty():
		lines.append(" [color=#ffcc00]conflict pending: '%s' is used by %s[/color]" % [
			_pending.name, ", ".join(PackedStringArray(_pending.conflicts))])
	return "\n".join(lines)


func _res_name(r: Resource) -> String:
	if r.resource_name != "":
		return r.resource_name
	if r.resource_path != "":
		return r.resource_path.get_file().get_basename()
	return "(unnamed)"


func _fmt(v: Variant) -> String:
	match typeof(v):
		TYPE_FLOAT: return "%.2f" % v
		TYPE_VECTOR2: return "(%.2f, %.2f)" % [v.x, v.y]
		TYPE_VECTOR3: return "(%.2f, %.2f, %.2f)" % [v.x, v.y, v.z]
	return str(v)


func _is_active(v: Variant) -> bool:
	match typeof(v):
		TYPE_BOOL: return v
		TYPE_FLOAT: return not is_zero_approx(v)
		TYPE_VECTOR2, TYPE_VECTOR3: return not v.is_zero_approx()
	return false
