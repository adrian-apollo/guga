@tool
extends RefCounted
## Generates a GDScript file with nested classes that mirror the tag hierarchy,
## so tags can be autocompleted in the script editor:
##
##     gameplay_tags.has_tag(GameTags.Character.Team.Alien)
##
## - A tag without children becomes a String constant.
## - A tag with children becomes a nested class that exposes its own name as TAG.

const Registry := preload("res://addons/gameplay_tags/classes/game_play_tags_registry.gd")

const CLASS_NAME := "GameTags"
const SELF_NAME_CONSTANT := "TAG"

# Names that cannot be used as identifiers; they get a "_" prefix.
const KEYWORDS: PackedStringArray = [
	"and", "as", "assert", "await", "break", "breakpoint", "class", "class_name",
	"const", "continue", "elif", "else", "enum", "extends", "false", "for", "func",
	"if", "in", "is", "match", "namespace", "not", "null", "or", "pass", "preload",
	"return", "self", "signal", "static", "super", "trait", "true", "var", "void",
	"while", "yield",
]


## Returns the source code of the constants script for the given tags.
static func generate(tags: PackedStringArray) -> String:
	# Map every path to its direct children ("" is the root).
	var children_of := {}
	for path in Registry.expand_tags(tags):
		var separator_index := path.rfind(Registry.SEPARATOR)
		var parent := "" if separator_index < 0 else path.substr(0, separator_index)
		if not children_of.has(parent):
			children_of[parent] = []
		children_of[parent].append(path)

	var lines: Array[String] = [
		"# GENERATED FILE - DO NOT EDIT.",
		"# Created by the Gameplay Tags plugin every time tags are saved in 'Edit game tags'.",
		"# Usage: GameTags.Character.Team.Alien (a tag with children exposes its own name as .TAG)",
		"class_name %s" % CLASS_NAME,
		"extends RefCounted",
	]
	_append_children(lines, children_of, "", 0)
	return "\n".join(PackedStringArray(lines)) + "\n"


## Writes the generated script to 'path'. The file is left untouched when its
## content would not change, so the editor does not reload it needlessly.
static func write_file(path: String, tags: PackedStringArray) -> Error:
	var content := generate(tags)
	if FileAccess.file_exists(path) and FileAccess.get_file_as_string(path) == content:
		return OK
	var dir_error := DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	if dir_error != OK:
		return dir_error
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(content)
	file.close()
	return OK


static func _append_children(
		lines: Array[String],
		children_of: Dictionary,
		parent: String,
		depth: int) -> void:
	var indent := "\t".repeat(depth)
	for path: String in children_of.get(parent, []):
		var segment := path.substr(path.rfind(Registry.SEPARATOR) + 1)
		var identifier := _to_identifier(segment)
		if children_of.has(path):
			lines.append("")
			lines.append("%sclass %s:" % [indent, identifier])
			lines.append("%s\tconst %s := \"%s\"" % [indent, SELF_NAME_CONSTANT, path])
			_append_children(lines, children_of, path, depth + 1)
		else:
			lines.append("%sconst %s := \"%s\"" % [indent, identifier, path])


## Makes a tag segment safe to use as a GDScript identifier.
static func _to_identifier(segment: String) -> String:
	if segment == SELF_NAME_CONSTANT:
		return segment + "_" # Would clash with the TAG constant of the parent class.
	if KEYWORDS.has(segment) or segment.substr(0, 1).is_valid_int():
		return "_" + segment
	return segment
