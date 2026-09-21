@tool
extends Label
class_name NerdFont

@export_category("NerdFont")
@export_range(1, 16384) var icon_size: int = 16: set = set_icon_size
@export_enum("cod", "custom", "dev", "extra", "fa", "fae", "iec", "indent", "indentation", "linux", "md", "oct", "pl", "ple", "pom", "seti", "weather") var icon_type: String = "md": set = set_icon_type
@export var icon_name: String = "home": set = set_icon_name

const icon_font: String = "res://addons/nerdfonts/fonts/SymbolsNerdFontMono-Regular.ttf"

const cheatsheet: Dictionary = preload("res://addons/nerdfonts/All.gd").all

func _init():
  horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  vertical_alignment = VERTICAL_ALIGNMENT_CENTER
  # disable some things, this is icon not text
  auto_translate = false
  localize_numeral_system = false

  set_icon_type(icon_type)
  set_icon_size(icon_size)
  set_icon_name(icon_name)

func set_icon_size(new_size: int):
  icon_size = clamp(new_size, 1, 16384)
  add_theme_font_size_override("font_size", icon_size)
  queue_redraw()

func set_icon_type(new_type: String):
  icon_type = new_type
  add_theme_font_override("font", load(icon_font))
  # Re-apply icon name to update the displayed glyph
  set_icon_name(icon_name)

func set_icon_name(new_name: String):
  icon_name = new_name
  if icon_type in cheatsheet and icon_name in cheatsheet[icon_type]:
    var iconcode = cheatsheet[icon_type][icon_name]
    set_text(iconcode)
