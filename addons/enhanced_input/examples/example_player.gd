extends CharacterBody2D
## Builds everything in code. Attach to a CharacterBody2D, enable the plugin, run.
## WASD moves, Space prints "jump!" once per press.

var move := InputAction.new()
var jump := InputAction.new()
var context := InputMappingContext.new()
var input_player:InputPlayer

func _ready() -> void:
	input_player = EnhancedInput.spawn_default_local_player_input()
	move.value_type = InputAction.ValueType.AXIS_2D
	jump.value_type = InputAction.ValueType.BOOL
	jump.debug = true  # prints state changes
	EnhancedInput.debug_overlay = true

	var swizzle := InputModifierSwizzle.new()  # key value goes to Y
	var negate := InputModifierNegate.new()
	context.mappings.assign([
		_key(KEY_W, move, [swizzle, negate]),  # up    -> (0,-1)
		_key(KEY_S, move, [swizzle]),          # down  -> (0, 1)
		_key(KEY_A, move, [negate]),           # left  -> (-1,0)
		_key(KEY_D, move, []),                 # right -> (1, 0)
		_key(KEY_SPACE, jump, [], [InputTriggerPressed.new()]),
	])
	input_player.add_context(context)
	jump.triggered.connect(func(_v: Variant): print("jump!"))


func _physics_process(_delta: float) -> void:
	velocity = move.value * 200.0
	move_and_slide()

func _exit_tree() -> void:
	input_player.remove_context(context)

func _key(
	keycode: Key,
	action: InputAction,
	modifiers: Array = [],
	triggers: Array = []
	)-> InputMapping:

	var m := InputMapping.new()
	var e := InputEventKey.new()
	e.keycode = keycode
	m.event = e
	m.action = action
	m.modifiers.assign(modifiers)
	m.triggers.assign(triggers)
	return m
