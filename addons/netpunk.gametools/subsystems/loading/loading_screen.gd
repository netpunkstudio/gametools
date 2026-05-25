extends CanvasLayer

var _override_background: Texture2D = null


func _ready() -> void:
	%Background.texture = _resolve_background()


## Called by LoadingManager before the screen is added to the tree.
## Overrides the ProjectSettings background lookup for this transition only.
func set_background(texture: Texture2D) -> void:
	_override_background = texture
	if is_node_ready():
		%Background.texture = texture


## Called by LoadingManager each frame with a value in [0.0, 1.0].
func set_progress(value: float) -> void:
	%ProgressBar.value = value


func _resolve_background() -> Texture2D:
	if _override_background != null:
		return _override_background

	var meta_key: String = ProjectSettings.get_setting(
		"gametools/loading/background_meta_key", "chapter")
	var keys: PackedStringArray = ProjectSettings.get_setting(
		"gametools/loading/background_keys", PackedStringArray())
	var paths: PackedStringArray = ProjectSettings.get_setting(
		"gametools/loading/background_paths", PackedStringArray())

	var meta := SaveManager.get_last_slot_meta()
	if not meta.is_empty() and meta.has(meta_key):
		var val := str(meta[meta_key])
		var idx := keys.find(val)
		if idx != -1 and idx < paths.size():
			var path := paths[idx]
			if not path.is_empty() and ResourceLoader.exists(path):
				return load(path) as Texture2D

	var default_path: String = ProjectSettings.get_setting(
		"gametools/loading/default_background", "")
	if not default_path.is_empty() and ResourceLoader.exists(default_path):
		return load(default_path) as Texture2D

	return null
