@tool
class_name GamePlayTagsContainer
extends Resource
##	Holds the gameplay tags owned by an actor and offers methods to query and edit them.
##
##	Matching rules (same idea as Unreal Engine):
##		- has_tag("A.B") is true if the container has "A.B" OR any child such as "A.B.C".
##		- has_tag_exact("A.B") is true only if "A.B" itself is in the container.
##		- has_tag_named("A") is true if theres an A tag, no matter hierarchy.
##
##	Methods that receive several tags accept a String:
##		-a PackedStringArray
##		-an Array of Strings
##		-another GamePlayTagsContainer.

#region signals
##	Emitted when a tag is added.
signal tag_added(tag: String)
##	Emitted when a tag is removed.
signal tag_removed(tag: String)
##	Emitted after any change to the tag list.
signal tags_changed
#endregion

##	The reference for the separator of tags on a tag string
const SEPARATOR := "."

##	The tags in this container. Edited from the inspector with the tag picker.
@export var tags: PackedStringArray = PackedStringArray():
	set(value):
		tags = _sanitize(value)
		tags_changed.emit()
		emit_changed()


#region QUERIES

##	Hierarchical match: true if the container has the tag or any of its children.
##	Example: with "Character.Team.Alien.Grey" in the container:
##	A querie with "Alien.Grey" returns true, as so will "Character.Team.Alien.Grey"
func has_tag( tag: String ) -> bool:
	if tag.is_empty():
		return false
	for owned in tags:
		if tag_matches(owned, tag):
			return true
	return false

##	Exact match: true only if the container has this very tag.
##	Example: with "Character.Team.Alien.Grey" in the container:
##	A querie with "Alien.Grey" returns false
##	with "Character.Team.Alien.Grey" returns true
func has_tag_exact(tag: String) -> bool:
	return tags.has(tag)

##	Name match: true if any tag in the container has a segment equal to the given
##	name, at any depth. No path is needed.
##	Example: with "Character.Team.Alien.Grey" in the container,
##	has_tag_named("Alien"), has_tag_named("Team") and has_tag_named("Grey") are all true,
##	while has_tag_named("Ali") is false (whole segments only, case-sensitive).
##	If several tags share that name in different branches, any of them matches.
##	Is recommended to not repeat tags or to mix lower cases with upper cases
func has_tag_named(tag_name: String) -> bool:
	if tag_name.is_empty():
		return false
	for owned in tags:
		if tag_name in owned.split(SEPARATOR):
			return true
	return false

##	True if at least one of the given tags matches hierarchically.
func has_any(source: Variant) -> bool:
	for tag in _extract_tags(source):
		if has_tag(tag):
			return true
	return false

##	True if every given tag matches hierarchically.
func has_all(source: Variant) -> bool:
	if !source:
		return false
	for tag in _extract_tags(source):
		if not has_tag(tag):
			return false
	return true

##	True if at least one of the given tags is present exactly.
func has_any_exact(source: Variant) -> bool:
	for tag in _extract_tags(source):
		if tags.has(tag):
			return true
	return false

##	True if every given tag is present exactly.
func has_all_exact( source: Variant ) -> bool:
	if !source:
		return false
	for tag in _extract_tags(source):
		if not tags.has(tag):
			return false
	return true

##	Returns a copy of the tags in this container.
func get_tags() -> PackedStringArray:
	return tags.duplicate()

##	Returns the tags that are descendants of the given parent tag.
func get_tags_under(parent: String) -> PackedStringArray:
	var result := PackedStringArray()
	var prefix := parent + SEPARATOR
	for owned in tags:
		if owned.begins_with(prefix):
			result.append(owned)
	return result

##	Returns the tags plus all of their implicit parents, sorted.
func get_expanded_tags() -> PackedStringArray:
	return GamePlayTagsRegistry.expand_tags(tags)

##	Returns how many tags there are in tags property
func size() -> int:
	return tags.size()

##	Returns true if tags is empty
func is_empty() -> bool:
	return tags.is_empty()

##	Static helper: true if 'owned' equals 'query' or is a child of it.
static func tag_matches(owned: String, query: String) -> bool:
	return owned == query or owned.begins_with(query + SEPARATOR)
#endregion

#region EDITING ( usable at runtime )

##	Adds a tag. Returns false if it is invalid or already present.
func add_tag( tag: String ) -> bool:
	tag = tag.strip_edges()
	if not GamePlayTagsRegistry.is_valid_tag_name(tag) or tags.has(tag):
		return false
	tags.append(tag)
	tag_added.emit(tag)
	tags_changed.emit()
	emit_changed()
	return true

##	Adds several tags. Returns how many were actually added.
func add_tags(source: Variant) -> int:
	var added := 0
	for tag in _extract_tags(source):
		if add_tag(tag):
			added += 1
	return added

##	Removes a tag. If include_children is true, its descendants are removed too.
##	Returns true if anything was removed.
func remove_tag(tag: String, include_children: bool = false) -> bool:
	var removed := PackedStringArray()
	var remaining := PackedStringArray()
	for owned in tags:
		if owned == tag or (include_children and owned.begins_with(tag + SEPARATOR)):
			removed.append(owned)
		else:
			remaining.append(owned)
	if removed.is_empty():
		return false
	tags = remaining # The setter emits tags_changed and changed.
	for owned in removed:
		tag_removed.emit(owned)
	return true

##	Removes several tags. Returns how many were actually removed.
func remove_tags(source: Variant) -> int:
	var removed := 0
	for tag in _extract_tags(source):
		if remove_tag(tag):
			removed += 1
	return removed

##	Removes every tag.
func clear() -> void:
	if tags.is_empty():
		return
	var old := tags.duplicate()
	tags = PackedStringArray()
	for owned in old:
		tag_removed.emit(owned)

##	Copies all tags from another container into this one.
##	Returns how many where actually added.
func append_container(other: GamePlayTagsContainer) -> int:
	if other == null:
		return 0
	return add_tags(other.tags)

#endregion

#region Internal methods

func _to_string() -> String:
	return "GamePlayTagsContainer(%s)" % ", ".join(tags)

func _sanitize(value: PackedStringArray) -> PackedStringArray:
	var result := PackedStringArray()
	for tag in value:
		var clean := tag.strip_edges()
		if not clean.is_empty() and not result.has(clean):
			result.append(clean)
	return result


func _extract_tags(source: Variant) -> PackedStringArray:
	var result := PackedStringArray()
	match typeof(source):
		TYPE_STRING, TYPE_STRING_NAME:
			result.append(String(source))
		TYPE_PACKED_STRING_ARRAY:
			result = source
		TYPE_ARRAY:
			for entry in source:
				result.append(String(entry))
		TYPE_OBJECT:
			if source is GamePlayTagsContainer:
				result = source.tags
	return result

#endregion
