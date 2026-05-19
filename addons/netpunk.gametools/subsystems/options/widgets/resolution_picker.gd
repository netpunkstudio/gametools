extends OptionButton

const _CANDIDATES: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160),
]

var _available: Array[Vector2i] = []


func _ready() -> void:
	var screen := DisplayServer.screen_get_size()
	clear()
	_available.clear()

	for res in _CANDIDATES:
		if res.x <= screen.x and res.y <= screen.y:
			_available.append(res)
			add_item("%d × %d" % [res.x, res.y])

	if _available.is_empty():
		_available.append(screen)
		add_item("%d × %d" % [screen.x, screen.y])

	var saved: Variant = OptionsManager.get_setting("display", "resolution", null)
	if saved is Array and saved.size() == 2:
		var idx := _available.find(Vector2i(saved[0], saved[1]))
		selected = maxi(idx, 0)
	else:
		selected = 0

	OptionsManager.setting_changed.connect(_on_options_setting_changed)
	item_selected.connect(_on_item_selected)


func _on_item_selected(idx: int) -> void:
	var res := _available[idx]
	OptionsManager.set_setting("display", "resolution", [res.x, res.y])


func _on_options_setting_changed(category: String, key: String, value: Variant) -> void:
	if category == "display" and key == "resolution" and value is Array and value.size() == 2:
		var idx := _available.find(Vector2i(value[0], value[1]))
		if idx >= 0:
			selected = idx
