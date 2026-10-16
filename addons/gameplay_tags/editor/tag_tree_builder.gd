@tool
extends RefCounted
#	Helper that fills a Tree control with the tag hierarchy.
#	Shared by the "Edit game tags" window and the inspector tag picker.

const Registry := preload("res://addons/gameplay_tags/game_play_tags_registry.gd")

const MISSING_COLOR := Color(1.0, 0.45, 0.45)

#	Rebuilds the tree from a list of tags (implicit parents are created automatically).
#	- checkable: show a checkbox on every item.
#	- selected: Dictionary of tag paths that must appear checked.
#	- filter: case-insensitive text; only matching tags (and their parents) are shown.
#	- missing: Dictionary of tag paths drawn in red (tags not defined in any file).
#	Returns a Dictionary mapping each tag path to its TreeItem.
static func build(
		tree: Tree,
		tags: PackedStringArray,
		checkable: bool = false,
		selected: Dictionary = {},
		filter: String = "",
		missing: Dictionary = {}) -> Dictionary:
	tree.clear()
	tree.hide_root = true
	var items := {"": tree.create_item()}
	var needle := filter.strip_edges().to_lower()
	for path in Registry.expand_tags(tags):
		if not needle.is_empty() and not path.to_lower().contains(needle):
			continue
		_ensure_item(tree, items, path, checkable, selected, missing)
	items.erase("")
	return items

static func _ensure_item(
		tree: Tree,
		items: Dictionary,
		path: String,
		checkable: bool,
		selected: Dictionary,
		missing: Dictionary) -> TreeItem:
	if items.has(path):
		return items[path]

	# Make sure the parent exists first (the root is stored under "").
	var separator_index := path.rfind(Registry.SEPARATOR)
	var parent_path := "" if separator_index < 0 else path.substr(0, separator_index)
	var parent_item := _ensure_item(tree, items, parent_path, checkable, selected, missing)

	var item := tree.create_item(parent_item)
	# The cell mode must be set BEFORE the text: changing the mode clears the cell text.
	if checkable:
		item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		item.set_editable(0, true)
	item.set_text(0, path.substr(separator_index + 1))
	item.set_metadata(0, path)
	if checkable:
		item.set_checked(0, selected.has(path))
	if missing.has(path):
		item.set_custom_color(0, MISSING_COLOR)
		item.set_tooltip_text(0, "This tag is not defined in any .gts file.")
	items[path] = item
	return item
