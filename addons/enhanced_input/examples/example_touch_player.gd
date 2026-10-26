extends CharacterBody2D
## Touch example (Android / iOS). Attach to a CharacterBody2D (with a CollisionShape2D) and run on a phone.
## - Move: on-screen buttons that feed the action with EnhancedInput.inject()  (touch option A).
## - Jump: touch the bottom-right zone, read from the touch screen             (touch option B).
## Test on PC: Project Settings > Input Devices > Pointing > Emulate Touch From Mouse.
## Tip: EnhancedInput.debug_overlay = true shows fingers, contexts and action states.

var move := InputAction.new()
var jump := InputAction.new()
var context := InputMappingContext.new()
var _held := {}  # Vector2 direction -> true, for every d-pad button currently pressed


func _ready() -> void:
	move.value_type = InputAction.ValueType.AXIS_2D
	jump.value_type = InputAction.ValueType.BOOL
	jump.triggers.append(InputTriggerPressed.new())  # fires once per touch, not every frame
	jump.triggered.connect(_on_jump)

	var zone := Rect2(0.6, 0.5, 0.4, 0.5)  # fractions of the screen: x, y, width, height
	var m := InputMapping.new()
	m.action = jump
	m.event = InputEventScreenTouch.new()
	m.touch_zone = zone
	context.mappings.append(m)
	EnhancedInput.add_context(context)

	_build_ui(zone)


func _physics_process(_delta: float) -> void:
	velocity = move.value * 250.0
	move_and_slide()


func _exit_tree() -> void:
	EnhancedInput.remove_context(context)


func _on_jump(_value) -> void:
	print("jump!")
	scale = Vector2(1.5, 1.5)  # visible feedback for any CharacterBody2D
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.2)


## d-pad buttons inject the sum of the held directions. Godot buttons follow the emulated mouse
## (one finger at a time); use TouchScreenButton if you need several buttons held at once.
func _hold(direction: Vector2, down: bool) -> void:
	if down:
		_held[direction] = true
	else:
		_held.erase(direction)
	var sum := Vector2.ZERO
	for d in _held:
		sum += d
	EnhancedInput.inject(move, sum)


func _build_ui(zone: Rect2) -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	var screen := get_viewport_rect().size

	var hint := ColorRect.new()  # shows where the jump zone is
	hint.color = Color(1, 1, 1, 0.15)
	hint.position = zone.position * screen
	hint.size = zone.size * screen
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var label := Label.new()
	label.text = "JUMP"
	hint.add_child(label)
	ui.add_child(hint)

	var pad := Vector2(40.0, screen.y - 260.0)
	_dpad_button(ui, "UP", pad + Vector2(80.0, 0.0), Vector2.UP)
	_dpad_button(ui, "DOWN", pad + Vector2(80.0, 160.0), Vector2.DOWN)
	_dpad_button(ui, "LEFT", pad + Vector2(0.0, 80.0), Vector2.LEFT)
	_dpad_button(ui, "RIGHT", pad + Vector2(160.0, 80.0), Vector2.RIGHT)


func _dpad_button(ui: CanvasLayer, text: String, pos: Vector2, direction: Vector2) -> void:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.custom_minimum_size = Vector2(80.0, 80.0)
	b.focus_mode = Control.FOCUS_NONE
	b.button_down.connect(_hold.bind(direction, true))
	b.button_up.connect(_hold.bind(direction, false))
	ui.add_child(b)
