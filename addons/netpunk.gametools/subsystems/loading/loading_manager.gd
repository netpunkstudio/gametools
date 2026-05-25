extends Node

## Path to the loading screen scene. Override before calling go_to() if you want
## a custom scene (must expose set_progress(float) and optionally set_background(Texture2D)).
var loading_screen_scene_path: String = \
	"res://addons/netpunk.gametools/subsystems/loading/loading_screen.tscn"

## Active transition. Assigned from ProjectSettings in _ready(); override at runtime
## with any LoadingTransition subclass for per-game control.
var transition: LoadingTransition = null

var _screen: Node = null
var _packed_scene: PackedScene = null
var _target_path: String = ""

enum _State { IDLE, TRANSITIONING_IN, WAITING_FOR_LOAD, TRANSITIONING_OUT }
var _state: _State = _State.IDLE


func _ready() -> void:
	_build_transition()


## Trigger a scene transition. background_override, if set, replaces the
## ProjectSettings-configured background lookup for this call only.
func go_to(scene_path: String, background_override: Texture2D = null) -> void:
	if _state != _State.IDLE:
		push_warning("LoadingManager: transition already in progress, ignoring go_to('%s')" % scene_path)
		return

	_target_path = scene_path
	_packed_scene = null

	var packed: PackedScene = load(loading_screen_scene_path)
	_screen = packed.instantiate()

	if background_override != null and _screen.has_method("set_background"):
		_screen.set_background(background_override)

	get_tree().root.add_child(_screen)
	ResourceLoader.load_threaded_request(scene_path)

	if transition != null:
		_state = _State.TRANSITIONING_IN
		_run_transition_in()
	else:
		_state = _State.WAITING_FOR_LOAD


func _process(_delta: float) -> void:
	if _state == _State.IDLE or _state == _State.TRANSITIONING_OUT:
		return
	if _target_path.is_empty():
		return

	var progress: Array = []
	var status := ResourceLoader.load_threaded_get_status(_target_path, progress)

	if _screen != null and _screen.has_method("set_progress"):
		_screen.set_progress(progress[0] if not progress.is_empty() else 0.0)

	match status:
		ResourceLoader.THREAD_LOAD_LOADED:
			_packed_scene = ResourceLoader.load_threaded_get(_target_path)
			_target_path = ""
			if _state == _State.WAITING_FOR_LOAD:
				_begin_transition_out()
			# if TRANSITIONING_IN: _run_transition_in coroutine handles it when done
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("LoadingManager: failed to load '%s'" % _target_path)
			_abort()


func _run_transition_in() -> void:
	await transition.do_transition_in(_screen)
	if _state != _State.TRANSITIONING_IN:
		return
	if _packed_scene != null:
		_begin_transition_out()
	else:
		_state = _State.WAITING_FOR_LOAD


func _begin_transition_out() -> void:
	_state = _State.TRANSITIONING_OUT
	_run_transition_out()


func _run_transition_out() -> void:
	if transition != null:
		await transition.do_transition_out(_screen)
	_finish()


func _finish() -> void:
	var scene := _packed_scene
	_packed_scene = null
	_state = _State.IDLE
	if _screen != null:
		_screen.queue_free()
		_screen = null
	get_tree().change_scene_to_packed(scene)


func _abort() -> void:
	_target_path = ""
	_packed_scene = null
	_state = _State.IDLE
	if _screen != null:
		_screen.queue_free()
		_screen = null


func _build_transition() -> void:
	var type: String = ProjectSettings.get_setting("gametools/loading/transition_type", "none")
	var dur_in: float = ProjectSettings.get_setting("gametools/loading/transition_duration_in", 0.4)
	var dur_out: float = ProjectSettings.get_setting("gametools/loading/transition_duration_out", 0.4)

	match type:
		"fade":
			var t := FadeTransition.new()
			t.duration_in = dur_in
			t.duration_out = dur_out
			transition = t
		"slide":
			var t := SlideTransition.new()
			t.duration_in = dur_in
			t.duration_out = dur_out
			t.direction = ProjectSettings.get_setting("gametools/loading/slide_direction", "left")
			transition = t
		"shader":
			var t := ShaderTransition.new()
			t.duration_in = dur_in
			t.duration_out = dur_out
			var shader_path: String = ProjectSettings.get_setting(
				"gametools/loading/transition_shader", "")
			if not shader_path.is_empty() and ResourceLoader.exists(shader_path):
				t.shader = load(shader_path)
			transition = t
		_:
			transition = null
