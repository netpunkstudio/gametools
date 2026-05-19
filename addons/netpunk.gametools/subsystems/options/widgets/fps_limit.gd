extends SpinBox

## Minimum selectable framerate. 0 means unlimited.
@export var min_fps: int = 0
## Maximum selectable framerate.
@export var max_fps: int = 240


func _ready() -> void:
	min_value = float(min_fps)
	max_value = float(max_fps)
	step = 1.0
	suffix = "FPS"
	set_value_no_signal(float(OptionsManager.get_setting("display", "fps_limit", 0)))

	OptionsManager.setting_changed.connect(_on_options_setting_changed)
	value_changed.connect(_on_value_changed)


func _on_value_changed(val: float) -> void:
	OptionsManager.set_setting("display", "fps_limit", int(val))


func _on_options_setting_changed(category: String, key: String, value: Variant) -> void:
	if category == "display" and key == "fps_limit":
		set_value_no_signal(float(value))
