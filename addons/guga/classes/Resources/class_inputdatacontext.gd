class_name InputDataContext extends Resource

@export var mapping_context:GUIDEMappingContext
@export var inputactions:Array[ GUIDEAction ]

func enablemappingcontext( ) -> void:
	if mapping_context:
		GUIDE.enable_mapping_context(mapping_context)

func disablemappingcontext( ) -> void:
	if mapping_context:
		GUIDE.disable_mapping_context(mapping_context)
