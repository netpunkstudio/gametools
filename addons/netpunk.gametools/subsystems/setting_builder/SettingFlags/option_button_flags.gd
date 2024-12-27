extends VBoxContainer

const OPTION_BUTTON_ENTRY = preload("res://addons/netpunk.gametools/subsystems/setting_builder/SettingFlags/option_button_entry.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_add_option_pressed() -> void:
	var new_entry = OPTION_BUTTON_ENTRY.instantiate()
	%Options.add_child(new_entry)
