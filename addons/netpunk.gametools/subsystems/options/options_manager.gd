extends Node

## Emitted whenever a single setting value changes (also emitted during cancel revert).
signal setting_changed(category: String, key: String, value: Variant)
## Emitted after commit() successfully saves settings to disk.
signal settings_committed
## Emitted after cancel() reverts to the pre-editing snapshot.
signal settings_cancelled

# Nested dict: { "display": {key: value}, "audio": {bus_name: linear_volume}, ... }
var _state: Dictionary = {}
# Snapshot taken at begin_editing() so cancel() can revert.
var _snapshot: Dictionary = {}


func _ready() -> void:
	load_and_apply()


# --- Edit Session ---

## Call when the player opens the options menu.
## Snapshots current state so cancel() can revert.
func begin_editing() -> void:
	_snapshot = _state.duplicate(true)


## Save all current settings to disk. Call on "Apply" / "OK".
func commit() -> void:
	SaveManager.save_settings(_state)
	_snapshot = {}
	settings_committed.emit()


## Revert to the state at the time begin_editing() was called. Call on "Cancel".
func cancel() -> void:
	_state = _snapshot.duplicate(true)
	_snapshot = {}
	for category: String in _state:
		for key: String in _state[category]:
			var value: Variant = _state[category][key]
			_apply_setting(category, key, value)
			setting_changed.emit(category, key, value)
	settings_cancelled.emit()


## Load saved settings from disk and apply them. Called automatically on ready.
func load_and_apply() -> void:
	var loaded := SaveManager.load_settings()
	if not loaded.is_empty():
		_state = loaded
		_apply_all()


# --- Settings API ---

## Apply and store a setting. Widgets call this on user interaction.
func set_setting(category: String, key: String, value: Variant) -> void:
	if not _state.has(category):
		_state[category] = {}
	_state[category][key] = value
	_apply_setting(category, key, value)
	setting_changed.emit(category, key, value)


## Read a setting from the in-memory state. Widgets call this in _ready().
func get_setting(category: String, key: String, default: Variant = null) -> Variant:
	if _state.has(category) and _state[category].has(key):
		return _state[category][key]
	return default


## Returns the setting keys registered for "gameplay" or "accessibility"
## in the plugin configuration dock. Returns an empty array for other categories.
func get_registered_keys(category: String) -> PackedStringArray:
	match category:
		"gameplay":
			return ProjectSettings.get_setting(
				"gametools/options/gameplay_keys", PackedStringArray())
		"accessibility":
			return ProjectSettings.get_setting(
				"gametools/options/accessibility_keys", PackedStringArray())
	return PackedStringArray()


# --- Internal ---

func _apply_all() -> void:
	for category: String in _state:
		for key: String in _state[category]:
			_apply_setting(category, key, _state[category][key])


func _apply_setting(category: String, key: String, value: Variant) -> void:
	match category:
		"display":
			_apply_display(key, value)
		"audio":
			_apply_audio(key, value)
		# "gameplay" and "accessibility" are game-specific.
		# Developers handle setting_changed signal for those categories.


func _apply_display(key: String, value: Variant) -> void:
	match key:
		"window_mode":
			DisplayServer.window_set_mode(value)
		"resolution":
			if value is Array and value.size() == 2:
				if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
					DisplayServer.window_set_size(Vector2i(value[0], value[1]))
		"vsync":
			DisplayServer.window_set_vsync_mode(value)
		"fps_limit":
			Engine.max_fps = value


func _apply_audio(key: String, value: Variant) -> void:
	var bus_idx := AudioServer.get_bus_index(key)
	if bus_idx < 0:
		return
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value) if value > 0.0 else -80.0)
