@tool
extends EditorPlugin

var dock: VBoxContainer
var response: RichTextLabel
var commands_entry: LineEdit

func _enter_tree() -> void:
	#	Main container
	dock = VBoxContainer.new()
	dock.name = "Git"
	dock.custom_minimum_size.y = 180

	#	Console exit
	response = RichTextLabel.new()
	response.size_flags_vertical = Control.SIZE_EXPAND_FILL
	response.scroll_following = true
	response.bbcode_enabled = true
	dock.add_child( response )

	#	Commands entry
	commands_entry = LineEdit.new()
	commands_entry.placeholder_text = "Write a Git command ( status, branch -a, push, pull )"
	commands_entry.text_submitted.connect(_on_comando_enviado)
	dock.add_child( commands_entry )

	#	Adds the dock to the lower panel
	add_control_to_bottom_panel(dock, "Git Terminal")
 
	_print( "[color=green]Git terminal ready. Write 'status' or 'git status' and press Enter.[/color]" )

func _exit_tree() -> void:
	if dock:
		remove_control_from_bottom_panel(dock)
		dock.queue_free()

func _on_comando_enviado(text: String) -> void:
	var command = text.strip_edges()
	commands_entry.clear()

	if command.is_empty():
		return

# If "git status" is wroten, "git" is removed
	if command.begins_with("git "):
		command = command.substr(4).strip_edges()
	
	_print("\n[color=white]$ git %s[/color]" % command )

	#	Separates every argument with blank spaces
	var arguments: PackedStringArray = command.split(" ", false)
	
	# 	Gets the project directory on the drive
	var proyect_path = ProjectSettings.globalize_path("res://")

	#	Stores terminal responses
	var output := []

	#	Execute git
	#	Note: true at the end captures errors (stderr) plus (stdout)
	var output_code = OS.execute("git", arguments, output, true)

	if output.size() > 0 and not output[0].is_empty():
		_print(output[0])
	else:
		if output_code == 0:
			_print("[color=green]Command completed without response.[/color]")
		else:
			_print("[color=red]Error on executing the command (Code %d).[/color]" % output_code)

	# If pull o checkout is requested, we ask Godot to update the view with the new files
	if "pull" in command or "checkout" in command or "switch" in command:
		EditorInterface.get_resource_filesystem().scan()

func _print(mensaje: String) -> void:
	response.append_text(mensaje + "\n")
