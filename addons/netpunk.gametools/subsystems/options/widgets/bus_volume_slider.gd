extends HSlider

## AudioServer bus name this slider controls (e.g. "Master", "Music", "SFX").
## Set this after instancing before adding to the scene tree.
@export var bus_name: String = "Master"


func _ready() -> void:
	min_value = 0.0
	max_value = 1.0
	step = 0.01
	set_value_no_signal(OptionsManager.get_setting("audio", bus_name, 1.0))

	OptionsManager.setting_changed.connect(_on_options_setting_changed)
	value_changed.connect(_on_value_changed)


func _on_value_changed(val: float) -> void:
	OptionsManager.set_setting("audio", bus_name, val)


func _on_options_setting_changed(category: String, key: String, new_value: Variant) -> void:
	if category == "audio" and key == bus_name:
		set_value_no_signal(new_value)
