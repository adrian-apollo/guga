@tool
extends EditorInspectorPlugin
## Replaces the default array editor of GamePlayTagsContainer.tags
## with a tag picker button.

const PropertyEditor := preload("res://addons/gameplay_tags/editor/tags_property_editor.gd")


func _can_handle(object: Object) -> bool:
	return object is GamePlayTagsContainer


func _parse_property(
		_object: Object,
		_type: Variant.Type,
		name: String,
		_hint_type: PropertyHint,
		_hint_string: String,
		_usage_flags: int,
		_wide: bool) -> bool:
	if name == "tags":
		add_property_editor(name, PropertyEditor.new())
		return true # Hides the default editor.
	return false
