# Enhanced Input (Godot 4)

Input system inspired by Unreal Engine 5 Enhanced Input.

## Install

1. Copy `addons/enhanced_input` into your project.
2. Project > Project Settings > Plugins > enable **Enhanced Input**.
   This registers the `EnhancedInput` autoload.

## Concepts

| Concept | Class | Purpose |
|---|---|---|
| Action | `InputAction` | Abstract input ("Jump", "Move"). Has a value type: BOOL, AXIS_1D, AXIS_2D, AXIS_3D. |
| Player | `InputPlayer` | One local player: own contexts, device filter and action instances. |
| Mapping | `InputMapping` | Binds a key/button/axis to an action, with modifiers and triggers. |
| Context | `InputMappingContext` | A group of mappings you can add/remove at runtime. |
| Modifier | `InputModifier*` | Transforms the raw value (Negate, Scalar, DeadZone, Swizzle, Smooth, ResponseCurve, ScaleByDelta). |
| Trigger | `InputTrigger*` | Decides when the action fires (Down, Pressed, Released, Hold, Tap, Pulse, Chorded, Combo). |

## Action events

`started`, `ongoing`, `triggered`, `completed`, `canceled` — each passes the current value.

Example with a Pressed trigger on Space:

```
frame 1: Space down -> started, triggered
frame 2: Space held -> completed
```

With a Down trigger (default):

```
frame 1: started, triggered
frame 2..n: triggered
frame n+1 (released): completed
```

## Quick example

```gdscript
var jump := InputAction.new()
var ctx := InputMappingContext.new()

func _ready() -> void:
	var m := InputMapping.new()
	m.action = jump
	m.event = InputEventKey.new()
	m.event.keycode = KEY_SPACE
	m.triggers.append(InputTriggerPressed.new())
	ctx.mappings.append(m)

	EnhancedInput.add_context(ctx, 0)
	jump.triggered.connect(func(_value): print("jump!"))
```

## Keyboard as Vector2 (WASD)

A key produces `Vector3(1, 0, 0)` when pressed. Modifiers move it to the right axis:

| Key | Modifiers | Result |
|---|---|---|
| D | none | `(1, 0)` |
| A | Negate | `(-1, 0)` |
| S | Swizzle | `(0, 1)` |
| W | Swizzle, Negate | `(0, -1)` |

Values of all mappings of the same action are summed, so W+S cancel out.
See `examples/example_player.gd` for the full code.

## Gamepad stick

Bind an `InputEventJoypadMotion` (axis 0, `axis_value` = 1.0 for right, -1.0 for left).
Add `InputModifierDeadZone` to ignore drift:

```gdscript
var e := InputEventJoypadMotion.new()
e.axis = JOY_AXIS_LEFT_X
e.axis_value = 1.0   # this mapping reads the "right" half of the axis
```

## Priority and input consumption

```gdscript
EnhancedInput.add_context(gameplay_ctx, 0)
EnhancedInput.add_context(menu_ctx, 10)  # higher priority wins
```

If a mapping in a higher-priority context uses a key while pressed, and its action has
`consume_input = true` (default), lower-priority contexts ignore that key.

## Debugging

Set `action.debug = true` to print every state change:

```
[InputAction jump] NONE -> TRIGGERED | value=true
[InputAction jump] TRIGGERED -> NONE | value=false
```

## Advanced triggers (phase 2)

| Trigger | Behavior | Main properties |
|---|---|---|
| `InputTriggerHold` | ONGOING while held, TRIGGERED after `hold_time`. Released early = `canceled`. | `hold_time`, `is_one_shot` |
| `InputTriggerTap` | TRIGGERED on release if held <= `tap_time`. Held longer = never fires. | `tap_time` |
| `InputTriggerPulse` | While held, TRIGGERED every `interval` seconds. | `interval`, `trigger_on_start`, `trigger_limit` |
| `InputTriggerChorded` | TRIGGERED only while `chord_action` is TRIGGERED. | `chord_action` |
| `InputTriggerCombo` | Steps in order, each within `step_time`, then the mapping's own input. | `combo_steps`, `step_time` |

### Hold: charge attack on Mouse Left (0.8 s)

```gdscript
var attack := InputAction.new()
var hold := InputTriggerHold.new()
hold.hold_time = 0.8
hold.is_one_shot = true

var m := InputMapping.new()
m.action = attack
m.event = InputEventMouseButton.new()
m.event.button_index = MOUSE_BUTTON_LEFT
m.triggers.append(hold)

attack.ongoing.connect(func(_v): print("charging..."))
attack.triggered.connect(func(_v): print("charged hit!"))
attack.canceled.connect(func(_v): print("released too early"))
```

### Chorded: Shift + Click

```gdscript
var shift := InputAction.new()      # mapped to KEY_SHIFT, in the same active context
var shift_click := InputAction.new()

var chord := InputTriggerChorded.new()
chord.chord_action = shift
# add `chord` to the triggers of the Mouse Left mapping of `shift_click`
```

### Combo: Down, Down, then Space

```gdscript
# `step_down` is an action mapped to KEY_S with InputTriggerPressed.
var combo := InputTriggerCombo.new()
combo.combo_steps = [step_down, step_down]   # Array[InputAction]
combo.step_time = 0.4
# add `combo` to the triggers of the Space mapping of `special_move`
special_move.triggered.connect(func(_v): print("special move!"))
```

### Smooth: soft camera / movement

```gdscript
var smooth := InputModifierSmooth.new()
smooth.speed = 8.0
# add `smooth` AFTER swizzle/negate in the mapping's modifiers
```

## Update mode and pause

`EnhancedInput` evaluates actions once per frame, in `_process` by default.
Switch to the physics step if your gameplay runs in `_physics_process`:

```gdscript
func _ready() -> void:
	EnhancedInput.update_mode = EnhancedInput.UpdateMode.PHYSICS
```

- `PROCESS`: signals are emitted every rendered frame.
- `PHYSICS`: signals are emitted every physics tick (timers like `Hold` use the physics delta).

By default the autoload keeps working while the tree is paused (`run_when_paused = true`).
Set `EnhancedInput.run_when_paused = false` to freeze it with the tree.
While it runs in pause, signals still reach your callbacks, so swap contexts when pausing:

```gdscript
func pause_game() -> void:
	get_tree().paused = true
	EnhancedInput.remove_context(gameplay_ctx)
	EnhancedInput.add_context(menu_ctx, 10)

func resume_game() -> void:
	get_tree().paused = false
	EnhancedInput.remove_context(menu_ctx)
	EnhancedInput.add_context(gameplay_ctx)
```

## Mouse motion (mouse look)

Bind an `InputEventMouseMotion`. It produces the pixel delta of the frame (`Vector3(dx, dy, 0)`),
summed if several motion events arrive before the next update.

```gdscript
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	look.value_type = InputAction.ValueType.AXIS_2D

	var sens := InputModifierScalar.new()
	sens.scalar = Vector3(0.002, 0.002, 1.0)   # sensitivity

	var m := InputMapping.new()
	m.action = look
	m.event = InputEventMouseMotion.new()
	m.modifiers.append(sens)
	ctx.mappings.append(m)
	EnhancedInput.add_context(ctx)

func _process(_delta: float) -> void:
	rotate_y(-look.value.x)
	camera.rotate_x(-look.value.y)
```

`look.value` always holds the current delta (it is zero when the mouse does not move).
For the `triggered` signal, scaled values can fall below the default threshold (0.5), so add
`InputTriggerDown` with a small `actuation_threshold` (e.g. 0.0001) to the mapping or the action.

## Action-level modifiers and triggers

`InputAction` has its own `modifiers` and `triggers`. They are appended to the ones of
**every mapping** of that action (mapping first, then action), like in UE5.
They are evaluated per mapping, not on the summed value.

```gdscript
var move := InputAction.new()
move.value_type = InputAction.ValueType.AXIS_2D
move.modifiers.append(InputModifierDeadZone.new())   # applies to all mappings of move

var jump := InputAction.new()
var hold := InputTriggerHold.new()
hold.hold_time = 0.3
jump.triggers.append(hold)   # every key bound to jump now needs a 0.3 s hold
```

If a mapping has no triggers and the action has none, `Down` is used. If only the action
has triggers, only those are used.

## Text fields (block while typing)

By default key presses are ignored while an editable `LineEdit` or `TextEdit` (also `CodeEdit`) has focus,
so typing "w" in a chat box does not move the player. Key releases still pass, so keys never get stuck.
Mouse, gamepad and touch are not affected.

```gdscript
EnhancedInput.block_when_typing = false   # disable the filter
```

## Touch screen

Two ways, you can mix them.

### 1. Inject values from code

Use your own `TouchScreenButton`, `Button` or custom joystick `Control` and feed the action:

```gdscript
func _on_jump_button_down() -> void:
	EnhancedInput.inject(jump, true)

func _on_jump_button_up() -> void:
	EnhancedInput.inject(jump, false)

func _on_stick_changed(direction: Vector2) -> void:
	EnhancedInput.inject(move, direction)
```

- Accepts `bool`, `int`/`float`, `Vector2` and `Vector3`.
- The value stays until you inject again. `false`/`0` releases.
- It goes through the **action's** modifiers and triggers (not mapping-level ones) and is summed
  with keyboard/gamepad values. It works without an active context.

### 2. Read the touch screen directly (zones and fingers)

Bind `InputEventScreenTouch` (button) or `InputEventScreenDrag` (drag delta) and set `touch_zone`,
the area where the finger must **start**, as fractions of the screen `Rect2(x, y, width, height)`.

```gdscript
# Jump button: bottom-right corner
var jump_m := InputMapping.new()
jump_m.action = jump
jump_m.event = InputEventScreenTouch.new()
jump_m.touch_zone = Rect2(0.75, 0.6, 0.25, 0.4)

# Camera look: right half of the screen
var look_m := InputMapping.new()
look_m.action = look
look_m.event = InputEventScreenDrag.new()
look_m.touch_zone = Rect2(0.5, 0.0, 0.5, 1.0)

ctx.mappings.append_array([jump_m, look_m])   # jump_m first: it claims the finger first
```

- Each finger (index) belongs to **one** mapping: the first one (context priority, then array order)
  whose zone contains the starting point. Put small zones (buttons) before large ones (look).
- One finger per mapping. A second finger on a busy mapping goes to the next matching one.
- `ScreenTouch` = 1 while the finger is down. `ScreenDrag` = pixel delta per frame, like mouse motion
  (use `InputModifierScalar` for sensitivity).
- Godot also emulates the mouse from touch (Project Settings > Input Devices > Pointing >
  *Emulate Mouse From Touch*). Disable it if you also bind mouse buttons or motion.
- To test on desktop, enable *Emulate Touch From Mouse* in the same section.

## Pointer position (mouse and touch)

Actions give deltas for motion. For the real screen position (viewport pixels) use:

```gdscript
var mouse := EnhancedInput.get_pointer_position()          # mouse
if EnhancedInput.is_finger_down(1):
	var finger := EnhancedInput.get_pointer_position(1)    # touch finger index 1
```

- `get_pointer_position()` / `get_pointer_position(-1)`: mouse.
- `get_pointer_position(n)`: finger `n`. A finger that is not down returns `Vector2.ZERO`,
  so check `is_finger_down(n)` first.
- Works without contexts or mappings and is updated on every event, so it is always current.
- Normalize with `pos / get_viewport().get_visible_rect().size` (same 0..1 space as `touch_zone`).

## Local multiplayer

Each `InputPlayer` has its own contexts, device filter, values and signals, and all players
share the same `.tres` resources. `EnhancedInput.get_player()` is the default player (index 0):
the `EnhancedInput.add_context()` shortcuts use it, and `get_action()` returns the original resource.

```gdscript
var p1 := EnhancedInput.get_player()            # keyboard + mouse + touch
p1.device = InputPlayer.NO_JOYPAD               # ...and ignore gamepads
var p2 := EnhancedInput.create_player(0)        # gamepad id 0
var p3 := EnhancedInput.create_player(1)        # gamepad id 1

for p in [p1, p2, p3]:
	p.add_context(on_foot)                      # same context for everyone

var move_p2 := p2.get_action(move)              # p2's own copy of "move"
p2.get_action(jump).triggered.connect(func(_v): print("player 2 jumps"))

func _physics_process(_delta: float) -> void:
	velocity = move_p2.value * 200.0
```

- `device`: joypad id the player listens to (`-1` = any, `InputPlayer.NO_JOYPAD` = none).
- `use_keyboard_mouse`: if true, keyboard, mouse and touch events also reach the player.
- `get_action(action)` returns the player's **own copy** of the action: `value`, `state` and
  signals are private to that player. Use it instead of the shared resource for every player
  except the default one.
- Priority and input consumption work inside each player, never between players.
- Joypad ids: see Godot's `Input.get_connected_joypads()`. For plug/unplug events, see below.

### Gamepad plug and unplug

`EnhancedInput` emits `joypad_connected(device)` and `joypad_disconnected(device)`.
They are only emitted on changes: gamepads already connected at startup need
`Input.get_connected_joypads()`.

```gdscript
func _ready() -> void:
	for id in Input.get_connected_joypads():
		_on_joypad_connected(id)
	EnhancedInput.joypad_connected.connect(_on_joypad_connected)
	EnhancedInput.joypad_disconnected.connect(_on_joypad_disconnected)

func _on_joypad_connected(id: int) -> void:
	var p := EnhancedInput.create_player(id)
	p.add_context(on_foot)
	print("Player %d joined with gamepad %d" % [EnhancedInput.players.size(), id])

func _on_joypad_disconnected(id: int) -> void:
	for p in EnhancedInput.players:
		if p.device == id and p != EnhancedInput.get_player():
			EnhancedInput.remove_player(p)
			print("Gamepad %d left" % id)
			break
```

A player is not removed automatically when its gamepad disappears: you decide
(remove it, pause the game, wait for the gamepad to come back...).
When a gamepad is unplugged, everything it was holding is released first (actions get `completed`/`canceled`,
values go back to zero), then `joypad_disconnected` is emitted.

### Two players on one keyboard

Both players read the keyboard, each with its own context (different keys):

```gdscript
var p1 := EnhancedInput.get_player()
var p2 := EnhancedInput.create_player(InputPlayer.NO_JOYPAD, true)
p1.add_context(wasd_ctx)      # W A S D + Space
p2.add_context(arrows_ctx)    # arrow keys + Enter
```

### Notes

- Remove a player with `EnhancedInput.remove_player(p)` (the default one cannot be removed).
  Indices in `EnhancedInput.players` shift down.
- `get_action()` copies the action when first used. Later changes to `value_type`, `consume_input`
  or `debug` on the original do not reach existing copies (modifiers and triggers arrays are shared).
- `InputTriggerChorded` and `InputTriggerCombo` read the actions of their own player.
- `inject()` also exists per player: `p2.inject(move, Vector2.RIGHT)`.
- Pointer positions (`get_pointer_position`) are global, not per player.

## Response curves and delta time

| Modifier | Behavior |
|---|---|
| `InputModifierResponseCurveExponential` | Per axis: `sign(v) * abs(v) ^ exponent`. |
| `InputModifierResponseCurveUserDefined` | Per axis: a `Curve` resource (X = abs(input) 0..1, Y = output). |
| `InputModifierScaleByDelta` | `value * delta`: "per second" becomes "per frame". |

### Exponential: finer stick control near the center

```gdscript
var dead := InputModifierDeadZone.new()
var curve := InputModifierResponseCurveExponential.new()
curve.exponent = Vector3(2.0, 2.0, 1.0)
# mapping.modifiers = [dead, curve]
```

With exponent 2: stick at 0.5 gives 0.25, at -0.5 gives -0.25, at 1.0 gives 1.0.

### User defined: any shape, edited in the Inspector

```gdscript
var m := InputModifierResponseCurveUserDefined.new()
m.curve_x = preload("res://stick_curve.tres")   # a Curve resource
m.curve_y = m.curve_x
```

In the Inspector, create a `Curve` and edit its points with Godot's curve editor.
An axis without curve stays unchanged. Inputs above 1.0 are clamped to 1.0 before sampling,
so use it for sticks and triggers, not for mouse deltas.

### Scale by delta: look speed in degrees per second

```gdscript
var speed := InputModifierScalar.new()
speed.scalar = Vector3(180.0, 180.0, 1.0)      # degrees per second at full stick
var dt := InputModifierScaleByDelta.new()
# mapping.modifiers = [dead, speed, dt]     (order matters: dt last)

func _process(_delta: float) -> void:
	rotation_degrees.y -= look.value.x            # already "per frame"
```

Full stick turns 180 degrees per second at 60 or 144 FPS. The result is small (about 3 per frame),
so read `look.value` instead of relying on `triggered`, or lower `actuation_threshold`.
With `update_mode = PHYSICS` the physics delta is used.

## Rebinding keys and saving them

Let players change which key/button does what, and keep it between sessions.
Rebinds belong to an `InputPlayer`: each player has its own and its own file.

**1. Name the mappings** you want to be rebindable (Inspector: *Mapping Name*), e.g. `jump_key`, `jump_pad`.
A mapping without name cannot be rebound. Mappings with the same name change together.

**2. Rebind from your options menu:**

```gdscript
var p := EnhancedInput.get_player()

func _on_change_jump_pressed() -> void:
	label.text = "Press a key..."
	p.start_rebind(&"jump_key")           # waits for the next key / button / axis

func _ready() -> void:
	p.rebind_finished.connect(func(name, event):
		label.text = InputPlayer.event_text(event)    # "K"
		p.save_bindings("user://bindings.cfg"))
	p.rebind_canceled.connect(func(name):
		label.text = InputPlayer.event_text(p.get_binding(name)))
```

**Taken keys: ask the player.** If the captured key is already used by another named mapping,
`rebind_finished` is not emitted. `rebind_conflict(name, event, conflicts)` is emitted instead and
nothing changes until you answer with `resolve_rebind()`:

```gdscript
p.rebind_conflict.connect(func(name, event, conflicts):
	dialog.dialog_text = "%s is already used by: %s" % [
		InputPlayer.event_text(event), ", ".join(PackedStringArray(conflicts))]
	dialog.show())

func _on_swap_pressed() -> void:      p.resolve_rebind(InputPlayer.ConflictChoice.SWAP)
func _on_replace_pressed() -> void:   p.resolve_rebind(InputPlayer.ConflictChoice.REPLACE)
func _on_both_pressed() -> void:      p.resolve_rebind(InputPlayer.ConflictChoice.KEEP_BOTH)
func _on_cancel_pressed() -> void:    p.resolve_rebind(InputPlayer.ConflictChoice.CANCEL)
```

Example: `jump_key` = Space, `attack_key` = K. The player rebinds `jump_key` and presses K:

| Choice | Result |
|---|---|
| `SWAP` | `jump_key` = K, `attack_key` = Space |
| `REPLACE` | `jump_key` = K, `attack_key` unbound |
| `KEEP_BOTH` | both on K |
| `CANCEL` | nothing changes |

After `SWAP`, `REPLACE` and `KEEP_BOTH`, `rebind_finished` is emitted. After `CANCEL`, `rebind_canceled`.
Conflicts are searched only among **named** mappings in the contexts currently added to the player.
Unbound mappings are saved too (`{"type": "none"}`). Escape (or `cancel_rebind()`) also cancels a pending conflict.

The captured event is consumed (it does not also trigger actions or UI). `Escape` cancels
(`p.cancel_key = KEY_NONE` lets you bind Escape). Direct rebind without waiting: `p.rebind(&"jump_key", event)`.

**3. Load at startup** (before or after adding contexts):

```gdscript
func _ready() -> void:
	p.add_context(on_foot)
	p.load_bindings("user://bindings.cfg")   # ERR_FILE_NOT_FOUND the first time: ignore it
```

| Function | Purpose |
|---|---|
| `start_rebind(name)` / `cancel_rebind()` / `is_rebinding()` | Capture the next input. |
| `rebind(name, event)` | Apply an event directly (no conflict check). |
| `find_conflicts(name, event)` | Names of the mappings that already use that event. |
| `resolve_rebind(choice)` | Answer a `rebind_conflict` (SWAP, REPLACE, KEEP_BOTH, CANCEL). |
| `unbind(name)` | Leave a mapping without input. |
| `reset_binding(name)` / `reset_all_bindings()` | Back to the original events. |
| `get_binding(name)` | Current event of a named mapping. |
| `InputPlayer.event_text(event)` | Label for UI ("Space", "Mouse Left"...). |
| `save_bindings(path)` / `load_bindings(path)` | Persist to a `ConfigFile`. |

- Supported events: key, mouse button, joypad button, joypad axis. Keys are matched by physical position.
- The mapping keeps its modifiers and triggers: rebinding `W` of a Move action to `T` keeps "up".
- Rebinds are per player: two players can use different keys for the same action.
- Saved format (`user://bindings.cfg`):

```
[bindings]
jump_key={"type": "key", "physical_keycode": 75, "keycode": 0}
```

## Debug overlay

Live on-screen text that shows what the addon understands. Off by default, always available
(also in exported games, so remember to turn it off or leave `debug_toggle_key` unset).

```gdscript
EnhancedInput.debug_overlay = true          # on / off from code
EnhancedInput.debug_toggle_key = KEY_F3     # optional: F3 toggles it
EnhancedInput.debug_only_active = true      # optional: hide idle actions
```

Example with two players:

```
Player 0 · keyboard/mouse · pads: none
 contexts: menu (10), on_foot (0)
  jump         BOOL     true             TRIGGERED
  move         AXIS_2D  (0.00, -1.00)    TRIGGERED
  attack       BOOL     true             ONGOING
  look         AXIS_2D  (0.00, 0.00)     NONE

Player 1 · no keyboard/mouse · pads: 0
 contexts: on_foot (0)
  jump         BOOL     false            NONE
  move         AXIS_2D  (0.72, 0.10)     TRIGGERED

Pointer · mouse (412, 230) · finger 0 (88, 600)
```

`state` is colored: gray `NONE`, yellow `ONGOING`, green `TRIGGERED`.
Action names come from `resource_name`, or the `.tres` file name.
The overlay also shows `rebind: press an input for '...'` and pending conflicts.

How to read it:

| You see | Probably |
|---|---|
| `value` true but state `NONE` | the trigger does not fire (check its type and `actuation_threshold`) |
| state `ONGOING` | a `Hold`, `Tap`, `Pulse` or `Combo` is waiting |
| action never changes | another context with higher priority consumed the input, or the mapping does not match the event |
| gamepad does nothing | the player filters another `device` (`pads:` line) |
| `contexts: none` | the context was never added (or was removed) for that player |

- It does not block the mouse and it is drawn above everything (CanvasLayer 128), also while paused.
- To print one action only, set `action.debug = true` (prints every state change to the Output panel).

## Notes

- `Chorded` and `Combo` read other actions' state from the previous frame (1 frame lag).
  Those actions must belong to an active context.
- Triggers and modifiers keep their runtime state in `EnhancedInput`, not in the resource,
  so the same `.tres` can be shared between mappings.

## Limits

- Pressing and releasing within one frame is not detected.
- `Combo` does not reset on wrong inputs.
- Action-level modifiers/triggers run per mapping, not on the summed value.
- Conflicts are searched only among named mappings in the contexts added to the player (`rebind()` does not check).
- No built-in on-screen joystick: build one with a `Control` and `EnhancedInput.inject()`.
- Keyboard, mouse and touch cannot be split by device: every player with `use_keyboard_mouse` receives them (use different contexts/keys).
