extends AIController

var caitree:C_AI_Tree

func _ready():
	caitree = _tree.add_component_to_actor( self, C_AI_Tree )
	caitree.ai_tree_scene = "uid://bn81e17yxdwdx"
