@tool
class_name GamePlayTagsRegistry
extends RefCounted
## Global access point to the tags defined in .gts files.
##
## A .gts file is plain JSON:
## {
##     "version": 1,
##     "tags": ["Character.State.Stunned", "Character.State.Burning"]
## }
##
## The folder that contains the .gts files is configured in
## Project Settings > gameplay_tags/tag_files_directory.

const SETTING_PATH := "gameplay_tags/tag_files_directory"
const DEFAULT_DIRECTORY := "res://"
const GENERATED_FILE_SETTING_PATH := "gameplay_tags/generated_constants_file"
const DEFAULT_GENERATED_FILE := "res://gameplay_tags/game_tags.gd"
const FILE_EXTENSION := "gts"
const FILE_VERSION := 1
const SEPARATOR := "."

static var _cache: PackedStringArray = PackedStringArray()
static var _cache_valid := false
static var _name_regex: RegEx


## Returns the folder (from the project settings) that holds the .gts files.
static func get_directory() -> String:
	var directory: String = ProjectSettings.get_setting(SETTING_PATH, DEFAULT_DIRECTORY)
	if directory.strip_edges().is_empty():
		directory = DEFAULT_DIRECTORY
	return directory.simplify_path()


## Returns the path of the generated GameTags script (from the project settings).
## An empty string means that generation is disabled.
static func get_generated_file_path() -> String:
	var path: String = ProjectSettings.get_setting(GENERATED_FILE_SETTING_PATH, DEFAULT_GENERATED_FILE)
	return path.strip_edges()


## Returns the full path of every .gts file found in the configured folder.
static func list_files() -> PackedStringArray:
	var result := PackedStringArray()
	var directory := get_directory()
	var dir := DirAccess.open(directory)
	if dir == null:
		return result
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir() and file_name.get_extension().to_lower() == FILE_EXTENSION:
			result.append(directory.path_join(file_name))
		file_name = dir.get_next()
	dir.list_dir_end()
	result.sort()
	return result


## Reads the explicit tags stored in a single .gts file.
static func load_file(path: String) -> PackedStringArray:
	var result := PackedStringArray()
	if not FileAccess.file_exists(path):
		return result
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("GamePlayTags: cannot open '%s' (error %d)." % [path, FileAccess.get_open_error()])
		return result
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY or typeof(parsed.get("tags")) != TYPE_ARRAY:
		push_warning("GamePlayTags: '%s' is not a valid .gts file." % path)
		return result
	for entry in parsed["tags"]:
		if typeof(entry) == TYPE_STRING and is_valid_tag_name(entry) and not result.has(entry):
			result.append(entry)
	return result


## Writes the given tags to a .gts file (creates the folder if needed).
static func save_file(path: String, tags: PackedStringArray) -> Error:
	var dir_error := DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	if dir_error != OK:
		return dir_error
	var sorted_tags := tags.duplicate()
	sorted_tags.sort()
	var data := {
		"version": FILE_VERSION,
		"tags": Array(sorted_tags),
	}
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return OK


## Returns every selectable tag across all .gts files, including the implicit
## parents of each tag (e.g. "A.B.C" also yields "A" and "A.B"). Sorted and cached.
static func get_all_tags() -> PackedStringArray:
	if not _cache_valid:
		var explicit := PackedStringArray()
		for path in list_files():
			for tag in load_file(path):
				if not explicit.has(tag):
					explicit.append(tag)
		_cache = expand_tags(explicit)
		_cache_valid = true
	return _cache.duplicate()


## Forces the next get_all_tags() call to re-read the files from disk.
static func reload() -> void:
	_cache_valid = false


## True if the tag is defined (explicitly or as a parent of a defined tag).
static func is_registered(tag: String) -> bool:
	return get_all_tags().has(tag)


## Adds the implicit parents of every tag and returns a sorted list.
static func expand_tags(tags: PackedStringArray) -> PackedStringArray:
	var seen := {}
	for tag in tags:
		var path := ""
		for part in tag.split(SEPARATOR):
			path = part if path.is_empty() else path + SEPARATOR + part
			seen[path] = true
	var result := PackedStringArray(seen.keys())
	result.sort()
	return result


## Valid names are segments of letters, digits and underscores joined by dots.
static func is_valid_tag_name(tag: String) -> bool:
	if tag.is_empty():
		return false
	if _name_regex == null:
		_name_regex = RegEx.new()
		_name_regex.compile("^[A-Za-z0-9_]+(\\.[A-Za-z0-9_]+)*$")
	return _name_regex.search(tag) != null
