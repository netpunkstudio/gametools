extends OptionButton

## Maps item index → DisplayServer.WindowMode value.
const _MODES: Array[int] = [
	DisplayServer.WINDOW_MODE_WINDOWED,
	DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN,
	DisplayServer.WINDOW_MODE_FULLSCREEN,
]
const _LABELS: Array[String] = ["Windowed", "Fullscreen", "Borderless Fullscreen"]


func _ready() -> void:
	clear()
	for i in _LABELS.size():
		add_item(_LABELS[i], i)

	var current: int = OptionsManager.get_setting("display", "window_mode", DisplayServer.WINDOW_MODE_WINDOWED)
	selected = maxi(_MODES.find(current), 0)

	OptionsManager.setting_changed.connect(_on_options_setting_changed)
	item_selected.connect(_on_item_selected)


func _on_item_selected(idx: int) -> void:
	OptionsManager.set_setting("display", "window_mode", _MODES[idx])


func _on_options_setting_changed(category: String, key: String, value: Variant) -> void:
	if category == "display" and key == "window_mode":
		var idx := _MODES.find(value)
		if idx >= 0:
			selected = idx
