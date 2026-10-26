class_name InputDebugOverlay
extends CanvasLayer
## On-screen debug text for EnhancedInput. Created and updated by EnhancedInput (debug_overlay = true).

var _label := RichTextLabel.new()
var _last_text := ""


func _init() -> void:
	layer = 128
	process_mode = Node.PROCESS_MODE_ALWAYS  # also visible while paused
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Consolas", "Menlo", "DejaVu Sans Mono", "monospace"])
	_label.bbcode_enabled = true
	_label.fit_content = true
	_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE  # never blocks clicks
	_label.position = Vector2(8.0, 8.0)
	_label.add_theme_font_override("normal_font", font)
	_label.add_theme_font_override("bold_font", font)
	_label.add_theme_font_size_override("normal_font_size", 14)
	_label.add_theme_font_size_override("bold_font_size", 14)
	_label.add_theme_color_override("default_color", Color.WHITE)
	_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_label.add_theme_constant_override("outline_size", 4)
	add_child(_label)


func show_text(bbcode: String) -> void:
	if bbcode != _last_text:
		_last_text = bbcode
		_label.text = bbcode
