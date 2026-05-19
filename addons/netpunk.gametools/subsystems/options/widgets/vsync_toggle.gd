extends CheckButton


func _ready() -> void:
	var current: int = OptionsManager.get_setting("display", "vsync", DisplayServer.VSYNC_ENABLED)
	button_pressed = current != DisplayServer.VSYNC_DISABLED

	OptionsManager.setting_changed.connect(_on_options_setting_changed)
	toggled.connect(_on_toggled)


func _on_toggled(pressed: bool) -> void:
	var mode := DisplayServer.VSYNC_ENABLED if pressed else DisplayServer.VSYNC_DISABLED
	OptionsManager.set_setting("display", "vsync", mode)


func _on_options_setting_changed(category: String, key: String, value: Variant) -> void:
	if category == "display" and key == "vsync":
		set_pressed_no_signal(value != DisplayServer.VSYNC_DISABLED)
