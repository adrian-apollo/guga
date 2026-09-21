@tool
extends EditorPlugin

var finder: Window

func _enter_tree():
	add_custom_type("NerdFont", "Label", preload("res://addons/nerdfonts/NerdFont.gd"), null)

	finder = preload("finder/window.tscn").instantiate()
	finder.theme = get_editor_interface().get_base_control().theme
	get_editor_interface().get_base_control().add_child(finder)
	add_tool_menu_item("NerdFont Icons", _on_finder_pressed)


func _exit_tree():
	remove_custom_type("NerdFont")
	remove_tool_menu_item("NerdFont Icons")
	if is_instance_valid(finder):
		finder.queue_free()


func _on_finder_pressed():
	finder.show_window()
