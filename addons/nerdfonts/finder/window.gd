@tool
extends AcceptDialog


const CATEGORIES: Array[String] = ["all", "cod", "custom", "dev", "extra", "fa", "fae", "iec", "indent", "indentation", "linux", "md", "oct", "pl", "ple", "pom", "seti", "weather"]

const cheatsheet: Dictionary = preload("../All.gd").all

var selected_categories: Array[String] = ["all"]
var all_icons_loaded: bool = false
var total_icon_count: int = 0
var is_loading: bool = false
var load_cancelled: bool = false
var first_popup: bool = true

const BATCH_SIZE: int = 50


func _ready() -> void:
	# Populate category list with multi-select
	var category_list := $Box/LeftPanel/CategoryList as ItemList
	category_list.clear()
	for cat in CATEGORIES:
		var idx = category_list.add_item(cat)
		if cat == "all":
			category_list.select(idx, false)
	category_list.multi_selected.connect(_on_category_multi_selected)
	category_list.item_selected.connect(_on_category_selected)


func _on_category_selected(index: int) -> void:
	_update_selected_categories()


func _on_category_multi_selected(index: int, selected: bool) -> void:
	_update_selected_categories()


func _update_selected_categories() -> void:
	var category_list := $Box/LeftPanel/CategoryList as ItemList
	selected_categories.clear()

	for i in range(category_list.item_count):
		if category_list.is_selected(i):
			selected_categories.append(CATEGORIES[i])

	# Handle "all" selection
	if "all" in selected_categories:
		selected_categories.clear()
		selected_categories.append("all")
		# Deselect others visually
		for i in range(category_list.item_count):
			if CATEGORIES[i] != "all":
				category_list.deselect(i)

	if selected_categories.is_empty():
		selected_categories.append("all")

	filter_visible_icons($Box/RightPanel/Filters/Search.text)


func _on_search_text_changed(new_text: String) -> void:
	filter_visible_icons(new_text)


func load_all_icons() -> void:
	if all_icons_loaded or is_loading:
		return

	is_loading = true
	load_cancelled = false

	var options := $Box/RightPanel/Scroll/Options as HFlowContainer
	var template := $Box/RightPanel/Option as Button

	# Show scroll area immediately
	$Box/RightPanel/Scroll.visible = true
	$Box/RightPanel/NoResults.visible = false
	$Box/RightPanel/StatusBar.visible = true

	# Count total icons
	total_icon_count = 0
	for cat in CATEGORIES:
		if cat != "all" and cat in cheatsheet:
			total_icon_count += cheatsheet[cat].size()

	var loaded := 0

	for cat in CATEGORIES:
		if cat == "all" or load_cancelled:
			continue
		if cat not in cheatsheet:
			continue

		var icons: Dictionary = cheatsheet[cat]

		for icon_name in icons.keys():
			if load_cancelled:
				break

			var option := template.duplicate() as Button
			option.set_meta(&"text", icon_name)
			option.set_meta(&"type", cat)
			options.add_child(option)

			var glyph: String = icons[icon_name]
			option.tooltip_text = cat + "-" + icon_name + "\nUnicode: " + String.num_uint64(glyph.unicode_at(0), 16, false)

			var option_icon := option.get_node(^"Margin/Box/Icon") as Label
			var option_name := option.get_node(^"Margin/Box/Name") as Label
			var option_badge := option.get_node(^"GroupBadge") as Label
			option_icon.icon_type = cat
			option_icon.icon_name = icon_name
			option_name.text = icon_name
			option_badge.text = cat
			option.name = (cat + "_" + icon_name).to_pascal_case().validate_node_name()
			option.visible = true

			loaded += 1

			if loaded % BATCH_SIZE == 0:
				$Box/RightPanel/StatusBar.text = "Loading %d / %d icons..." % [loaded, total_icon_count]
				await get_tree().process_frame

	all_icons_loaded = true
	is_loading = false

	if not load_cancelled:
		filter_visible_icons($Box/RightPanel/Filters/Search.text)


func filter_visible_icons(search_term: String = "") -> void:
	var options := $Box/RightPanel/Scroll/Options as HFlowContainer
	var visible_count: int = 0
	var search_lower := search_term.to_lower()
	var show_all := "all" in selected_categories

	for option in options.get_children():
		var icon_name: String = option.get_meta(&"text", "")
		var icon_category: String = option.get_meta(&"type", "")

		var category_match := show_all or icon_category in selected_categories
		var search_match := search_term.is_empty() or icon_name.to_lower().find(search_lower) > -1

		var should_show := category_match and search_match
		option.visible = should_show
		if should_show:
			visible_count += 1

	$Box/RightPanel/Scroll.visible = visible_count > 0
	$Box/RightPanel/NoResults.visible = visible_count == 0
	$Box/RightPanel/StatusBar.text = "Showing %d of %d icons" % [visible_count, total_icon_count]
	$Box/RightPanel/StatusBar.visible = true


func show_window() -> void:
	if first_popup:
		popup_centered()
		first_popup = false
		var search := $Box/RightPanel/Filters/Search as LineEdit
		search.placeholder_text = "Filter by name..."
		if has_theme_icon(&"Search", &"EditorIcons"):
			search.right_icon = get_theme_icon(&"Search", &"EditorIcons")
		await get_tree().create_timer(0.1).timeout
		load_all_icons()
	else:
		popup()
