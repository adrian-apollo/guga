extends CanvasLayer

@export var inputcontexdata:InputDataContext

@export_group("Labels")
@export var resources:Label

@export_category(" FPS ")
@export var fps_Max:Label
@export var fps_Min:Label
@export var fps_Avg:Label
@export var fps_Curr:Label

@export_category(" Ram ")
@export var RAM_Max:Label
@export var RAM_Min:Label
@export var RAM_Avg:Label
@export var RAM_Curr:Label

@export_category(" Nodes ")
@export var nodes_Max:Label
@export var nodes_Min:Label
@export var nodes_Avg:Label
@export var nodes_Curr:Label

@export_category("World")
@export var nodes_root:Label
@export var current_level:Label
@export var current_player:Label

@export_category("Performance")
@export var primitives:Label
@export var drawcalls:Label

@export_category(" Setup ")
@export var starthide:bool

######################################################################

func _ready() -> void:

	set_layer(RenderingServer.CANVAS_LAYER_MAX)

	fps_Curr.text = "%3.0f" % ( Engine.get_frames_per_second() )
	nodes_Curr.text = str( get_tree().get_node_count() )
	RAM_Curr.text = "%3.1f" % ( OS.get_static_memory_usage() / 1048576.0 )

	if starthide:
		hide()

	if inputcontexdata:
		inputcontexdata.enablemappingcontext()
		inputcontexdata.inputactions[0].just_triggered.connect(togglevisibility)

func _physics_process(_delta: float) -> void:
	primitives.text = "Primitives: " + str( Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME ) )
	drawcalls.text = "Drawcalls: " + str( Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME ) )
	fps_Curr.text = "%3.0f" % ( Engine.get_frames_per_second() )
	nodes_Curr.text = str( get_tree().get_node_count() )
	RAM_Curr.text = "%3.1f" % ( OS.get_static_memory_usage() / 1048576.0 )
	nodes_root.text = getrootnodesstring()

	updatevalues(fps_Max, fps_Min, fps_Avg, fps_Curr)
	updatevalues(RAM_Max, RAM_Min, RAM_Avg, RAM_Curr)
	updatevalues(nodes_Max, nodes_Min, nodes_Avg, nodes_Curr)

######################################################################
func updatelevellabel( levelname:String ) -> void:
	current_level.text = "Level: " + levelname

func updatevalues(maxv:Label, minv:Label, avgv:Label, currv:Label ) -> void:

	avgv.text = "%3.0f" % ( ( avgv.text.to_float() + currv.text.to_float() ) / 2 )

	if currv.text.to_float() > maxv.text.to_float():
		maxv.text = currv.text

	if currv.text.to_float() < minv.text.to_float():
		minv.text = currv.text

func togglevisibility() -> void:
	if visible:
		hide()
	else:
		show()

func getrootnodesstring() -> String:
	var nodes:String = ""

	for i in get_tree().root.get_child_count():
		nodes += get_tree().root.get_child(i).name + "\n"

	return nodes

######################################################################
