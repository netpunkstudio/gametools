extends Node

## Path to the loading screen scene. Override before calling go_to() if you
## want a custom scene (must expose set_progress(float) method).
var loading_screen_scene_path: String = \
	"res://addons/netpunk.gametools/subsystems/loading/loading_screen.tscn"

var _screen: Node = null
var _target_path: String = ""


## Trigger a scene transition through the loading screen.
## The loading screen appears immediately; the target scene loads in the background.
func go_to(scene_path: String) -> void:
	if not _target_path.is_empty():
		push_warning("LoadingManager: transition already in progress, ignoring go_to('%s')" % scene_path)
		return
	_target_path = scene_path
	var packed: PackedScene = load(loading_screen_scene_path)
	_screen = packed.instantiate()
	get_tree().root.add_child(_screen)
	ResourceLoader.load_threaded_request(scene_path)


func _process(_delta: float) -> void:
	if _target_path.is_empty():
		return
	var progress: Array = []
	var status := ResourceLoader.load_threaded_get_status(_target_path, progress)
	if _screen != null and _screen.has_method("set_progress"):
		_screen.set_progress(progress[0] if not progress.is_empty() else 0.0)
	match status:
		ResourceLoader.THREAD_LOAD_LOADED:
			_complete()
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("LoadingManager: failed to load '%s'" % _target_path)
			_abort()


func _complete() -> void:
	var packed_scene: PackedScene = ResourceLoader.load_threaded_get(_target_path)
	_target_path = ""
	if _screen != null:
		_screen.queue_free()
		_screen = null
	get_tree().change_scene_to_packed(packed_scene)


func _abort() -> void:
	_target_path = ""
	if _screen != null:
		_screen.queue_free()
		_screen = null
