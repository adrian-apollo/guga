@tool
extends Window
#	"Edit game tags" window (Project > Tools).
#	Shows the tag hierarchy of one .gts file and lets the user add, remove,
#	refresh and save tags.

#region Constants
const Registry := preload("res://addons/gameplay_tags/game_play_tags_registry.gd")
const TreeBuilder := preload("res://addons/gameplay_tags/editor/tag_tree_builder.gd")

const WINDOW_TITLE := "Edit game tags"
const DEFAULT_FILE_NAME := "game_tags.gts"
const ERROR_COLOR := Color(1.0, 0.45, 0.45)
#endregion

#region	Explicit tags of the file being edited (tag path -> true).
var _tags: Dictionary = {}
var _current_file := ""
var _current_index := 0
var _dirty := false
var _pending_action := Callable()

var _file_option: OptionButton
var _tree: Tree
var _status: Label
var _add_dialog: ConfirmationDialog
var _add_edit: LineEdit
var _add_hint: Label
var _confirm_dialog: ConfirmationDialog

#endregion

func _init() -> void:
	title = WINDOW_TITLE
	min_size = Vector2i(520, 480)
	size = Vector2i(720, 620)
	transient = true
	visible = false # Windows are visible by default when added to the tree.
	close_requested.connect(hide)


func _ready() -> void:
	_build_ui()

#	Opens the window. Unsaved changes are kept if the window was closed while dirty.
func open_editor() -> void:
	if not _dirty:
		reload()
	if visible:
		grab_focus()
	else:
		popup_centered(Vector2i(720, 620))

#	Re-scans the .gts folder and reloads the selected file from disk.
func reload() -> void:
	Registry.reload()
	_refresh_file_list()
	_load_current_file()

#region UI construction

func _build_ui() -> void:
	var background := Panel.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 8)
	add_child(margin)

	var root_box := VBoxContainer.new()
	margin.add_child(root_box)

	# File selector row.
	var file_row := HBoxContainer.new()
	root_box.add_child(file_row)
	var file_label := Label.new()
	file_label.text = "File:"
	file_row.add_child(file_label)
	_file_option = OptionButton.new()
	_file_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_file_option.item_selected.connect(_on_file_selected)
	file_row.add_child(_file_option)

	# Hierarchy tree.
	_tree = Tree.new()
	_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tree.hide_root = true
	root_box.add_child(_tree)

	_status = Label.new()
	_status.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	root_box.add_child(_status)

	# Button row.
	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_END
	root_box.add_child(button_row)
	_add_button(button_row, "Add", _on_add_pressed)
	_add_button(button_row, "Remove", _on_remove_pressed)
	_add_button(button_row, "Refresh", _on_refresh_pressed)
	_add_button(button_row, "Save", _on_save_pressed)

	_build_add_dialog()

	_confirm_dialog = ConfirmationDialog.new()
	_confirm_dialog.confirmed.connect(_on_confirm_accepted)
	add_child(_confirm_dialog)


func _add_button(parent: Control, text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.x = 90
	button.pressed.connect(callback)
	parent.add_child(button)


func _build_add_dialog() -> void:
	_add_dialog = ConfirmationDialog.new()
	_add_dialog.title = "Add tag"
	_add_dialog.ok_button_text = "Add"
	_add_dialog.confirmed.connect(_on_add_confirmed)

	var box := VBoxContainer.new()
	_add_dialog.add_child(box)

	var prompt := Label.new()
	prompt.text = "Full tag name (use '.' to separate levels):"
	box.add_child(prompt)

	_add_edit = LineEdit.new()
	_add_edit.placeholder_text = "Character.State.Stunned"
	_add_edit.custom_minimum_size.x = 380
	_add_edit.text_changed.connect(_on_add_text_changed)
	box.add_child(_add_edit)
	_add_dialog.register_text_enter(_add_edit)

	_add_hint = Label.new()
	_add_hint.add_theme_color_override("font_color", ERROR_COLOR)
	box.add_child(_add_hint)

	add_child(_add_dialog)

#endregion

#region File handling

func _refresh_file_list() -> void:
	var files := Registry.list_files()
	var previous := _current_file
	_file_option.clear()

	if files.is_empty():
		# Nothing on disk yet: the first save will create a default file.
		var new_path := Registry.get_directory().path_join(DEFAULT_FILE_NAME)
		_file_option.add_item(DEFAULT_FILE_NAME + " (new)")
		_file_option.set_item_metadata(0, new_path)
		_file_option.set_item_tooltip(0, new_path)
		_file_option.select(0)
		_current_index = 0
		_current_file = new_path
		return

	var selected_index := 0
	for i in files.size():
		_file_option.add_item(files[i].get_file())
		_file_option.set_item_metadata(i, files[i])
		_file_option.set_item_tooltip(i, files[i])
		if files[i] == previous:
			selected_index = i
	_file_option.select(selected_index)
	_current_index = selected_index
	_current_file = files[selected_index]

func _load_current_file() -> void:
	_tags.clear()
	for tag in Registry.load_file(_current_file):
		_tags[tag] = true
	_set_dirty(false)
	_rebuild_tree()
	_set_status("Loaded %d tag(s) from %s." % [_tags.size(), _current_file.get_file()])

func _on_file_selected(index: int) -> void:
	if _dirty:
		_file_option.select(_current_index)
		_set_status("Save or refresh before switching files.", true)
		return
	_current_index = index
	_current_file = _file_option.get_item_metadata(index)
	_load_current_file()

#endregion

#region Buttons

func _on_add_pressed() -> void:
	var selected_item := _tree.get_selected()
	# Prefill with the selected tag so children are quick to create.
	_add_edit.text = "" if selected_item == null else str(selected_item.get_metadata(0)) + Registry.SEPARATOR
	_on_add_text_changed(_add_edit.text)
	_add_dialog.popup_centered()
	_add_edit.grab_focus()
	_add_edit.caret_column = _add_edit.text.length()

func _on_add_text_changed(text: String) -> void:
	var tag := text.strip_edges()
	var message := ""
	var valid := Registry.is_valid_tag_name(tag)
	if tag.is_empty():
		valid = false
	elif not valid:
		message = "Use letters, digits and underscores, separated by dots."
	elif _tags.has(tag):
		valid = false
		message = "This tag already exists."
	_add_hint.text = message
	_add_dialog.get_ok_button().disabled = not valid

func _on_add_confirmed() -> void:
	var tag := _add_edit.text.strip_edges()
	if not Registry.is_valid_tag_name(tag) or _tags.has(tag):
		return
	_tags[tag] = true
	_set_dirty(true)
	_rebuild_tree(tag)
	_set_status("Added '%s'." % tag)

func _on_remove_pressed() -> void:
	var item := _tree.get_selected()
	if item == null:
		_set_status("Select a tag to remove.", true)
		return
	var path := str(item.get_metadata(0))
	_ask_confirmation(
		"Remove \"%s\" and all of its child tags?" % path,
		_remove_tag.bind(path))

func _remove_tag(path: String) -> void:
	var prefix := path + Registry.SEPARATOR
	for key in _tags.keys():
		if key == path or str(key).begins_with(prefix):
			_tags.erase(key)
	_set_dirty(true)
	_rebuild_tree()
	_set_status("Removed '%s'." % path)

func _on_refresh_pressed() -> void:
	if _dirty:
		_ask_confirmation("Discard unsaved changes and reload from disk?", reload)
	else:
		reload()

func _on_save_pressed() -> void:
	var error := Registry.save_file(_current_file, PackedStringArray(_tags.keys()))
	if error != OK:
		_set_status("Could not save '%s' (error %d)." % [_current_file, error], true)
		return
	_set_dirty(false)
	Registry.reload()
	# Make the new file visible in the FileSystem dock and refresh the file list.
	EditorInterface.get_resource_filesystem().scan()
	_refresh_file_list()
	_set_status("Saved %d tag(s) to %s." % [_tags.size(), _current_file.get_file()])

#endregion

#region Helpers

func _ask_confirmation(text: String, action: Callable) -> void:
	_pending_action = action
	_confirm_dialog.dialog_text = text
	_confirm_dialog.popup_centered()

func _on_confirm_accepted() -> void:
	if _pending_action.is_valid():
		_pending_action.call()
	_pending_action = Callable()

func _rebuild_tree(select_path: String = "") -> void:
	var items := TreeBuilder.build(_tree, PackedStringArray(_tags.keys()))
	if not select_path.is_empty() and items.has(select_path):
		var item: TreeItem = items[select_path]
		item.select(0)
		_tree.scroll_to_item(item)

func _set_dirty(value: bool) -> void:
	_dirty = value
	title = WINDOW_TITLE + (" *" if _dirty else "")

func _set_status(text: String, is_error: bool = false) -> void:
	_status.text = text
	if is_error:
		_status.add_theme_color_override("font_color", ERROR_COLOR)
	else:
		_status.remove_theme_color_override("font_color")

#endregion
