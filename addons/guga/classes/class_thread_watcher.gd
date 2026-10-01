class_name ThreadWatcher extends Node

var target_uid: String
var callback_progress: Callable
var callback_complete: Callable

func _init(uid: String, progress_cb: Callable, complete_cb: Callable):
	target_uid = uid
	callback_complete = complete_cb
	callback_progress = progress_cb

var progress_array:Array = []
var status
func _physics_process(_delta: float):
	status = ResourceLoader.load_threaded_get_status( target_uid, progress_array )
	
	if progress_array.size() > 0 and callback_progress.is_valid():
		callback_progress.call( progress_array[0] )

	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			return

		ResourceLoader.THREAD_LOAD_LOADED:
			if callback_complete.is_valid():
				callback_complete.call( ResourceLoader.load_threaded_get( target_uid ) )
			set_physics_process(false)
			queue_free()

		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			set_physics_process(false)
			if callback_complete.is_valid():
				callback_complete.call(null)
			queue_free()
