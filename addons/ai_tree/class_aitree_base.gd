class_name AITreeBase
extends Node

func _ready() -> void:
	enter_first_state()

func enter_first_state():
	for c in get_children():
		if c is AIState:
			c.call_deferred("start")
			return

#region watchers
var watchers:Array[ AIWatcherBase ]

func add_watcher( w:AIWatcherBase ):
	watchers.push_back( w )

func remove_watcher( watcher:AIWatcherBase ):
	watchers.erase( watcher )

func get_watcher_property( property:StringName ) -> Variant:
	if property.is_empty():
		return null
	for w in watchers:
		if w.get( &"player" ):
			return w.get( property )
	return null

func get_watcher_with_property( property:StringName ) -> AIWatcherBase:
	for w in watchers:
		if w.get( property ) != null:
			return w
	return null
#endregion
