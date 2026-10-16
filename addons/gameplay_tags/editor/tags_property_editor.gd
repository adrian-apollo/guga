@tool
extends EditorProperty
#	Inspector control for GamePlayTagsContainer.tags.
#	Shows an "Edit tags" button plus the list of current tags below it.
#	The button opens a checkbox tree with every tag defined in the project's .gts files.

const Registry := preload("res://addons/gameplay_tags/game_play_tags_registry.gd")
const TreeBuilder := preload("res://addons/gameplay_tags/editor/tag_tree_builder.gd")

var _button: Button
var _tags_label: Label
var _dialog: ConfirmationDialog
var _filter_edit: LineEdit
var _tree: Tree
var _hint: Label

# Tags currently checked in the dialog (tag path -> true).
var _selected: Dictionary = {}

func _init() -> void:
	_button = Button.new()
	_button.text = "Edit tags..."
	_button.clip_text = true
	_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_button.pressed.connect(_open_dialog)
	add_child(_button)
	add_focusable(_button)

	# Read-only list of the current tags, shown under the button.
	_tags_label = Label.new()
	_tags_label.visible = false
	add_child(_tags_label)
	set_bottom_editor(_tags_label)

func _exit_tree() -> void:
	#	The dialog lives in the editor base control, so free it with this editor
	if is_instance_valid(_dialog):
		_dialog.queue_free()

#	Called by the inspector whenever the edited value changes.
func _update_property() -> void:
	var current := _get_current_tags()
	_button.text = "Edit tags (%d)..." % current.size()
	_tags_label.text = "\n".join(current)
	_tags_label.visible = not current.is_empty()

func _get_current_tags() -> PackedStringArray:
	var value: Variant = get_edited_object().get(get_edited_property())
	if typeof(value) == TYPE_PACKED_STRING_ARRAY:
		return value
	return PackedStringArray()

func _open_dialog() -> void:
	_ensure_dialog()
	Registry.reload() # Pick up changes made in the "Edit game tags" window.
	_selected.clear()
	for tag in _get_current_tags():
		_selected[tag] = true
	_filter_edit.text = ""
	_rebuild_tree()
	_dialog.popup_centered(Vector2i(480, 520))
	_filter_edit.grab_focus()

func _ensure_dialog() -> void:
	if is_instance_valid(_dialog):
		return
	_dialog = ConfirmationDialog.new()
	_dialog.title = "Select tags"
	_dialog.ok_button_text = "Apply"
	_dialog.confirmed.connect(_on_confirmed)

	var box := VBoxContainer.new()
	_dialog.add_child(box)

	_filter_edit = LineEdit.new()
	_filter_edit.placeholder_text = "Filter..."
	_filter_edit.clear_button_enabled = true
	_filter_edit.text_changed.connect(_on_filter_changed)
	box.add_child(_filter_edit)

	_tree = Tree.new()
	_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tree.custom_minimum_size = Vector2(0, 360)
	_tree.hide_root = true
	_tree.item_edited.connect(_on_item_edited)
	box.add_child(_tree)

	_hint = Label.new()
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_hint)

	# Parent the popup to the editor itself so the inspector layout cannot interfere.
	EditorInterface.get_base_control().add_child(_dialog)

func _rebuild_tree() -> void:
	var known := Registry.get_all_tags()
	var known_lookup := {}
	for tag in known:
		known_lookup[tag] = true

	# Keep tags that are checked but no longer defined, flagged in red.
	var all_tags := known.duplicate()
	var missing := {}
	for path in _selected.keys():
		if not known_lookup.has(path):
			all_tags.append(path)
			missing[path] = true

	TreeBuilder.build(_tree, all_tags, true, _selected, _filter_edit.text, missing)
	if known.is_empty():
		_hint.text = "No tags defined yet. Use Project > Tools > Edit game tags."
	elif not missing.is_empty():
		_hint.text = "Tags in red are not defined in any .gts file."
	else:
		_hint.text = ""

func _on_filter_changed(_text: String) -> void:
	_rebuild_tree()

func _on_item_edited() -> void:
	var item := _tree.get_edited()
	if item == null:
		return
	var path := str(item.get_metadata(0))
	if item.is_checked(0):
		_selected[path] = true
	else:
		_selected.erase(path)

func _on_confirmed() -> void:
	var result := PackedStringArray(_selected.keys())
	result.sort()
	emit_changed(get_edited_property(), result)
