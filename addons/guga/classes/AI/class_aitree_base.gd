class_name AITreeBase
extends Node

var watchers:Array[AIWatcherBase]

func add_watcher(watcher:AIWatcherBase):
	watchers.push_back( watcher )

func remove_watcher(watcher:AIWatcherBase):
	watchers.erase(watcher)

func get_watcher_property(property:StringName) -> Variant:
	for w in watchers:
		if w.get(property) != null:
			return w.get( property )
	return null

func get_watcher_with_property(property:StringName) -> AIWatcherBase:
	for w in watchers:
		if w.get(property) != null:
			return w
	return null
