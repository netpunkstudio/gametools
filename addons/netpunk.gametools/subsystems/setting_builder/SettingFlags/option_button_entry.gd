extends HBoxContainer

@export var user_editable: bool = true
@export var text: String

func _ready() -> void:
	%MenuButton.get_popup().connect("id_pressed", _on_menu_item_pressed)
	%MenuButton.visible = user_editable
	
	if text != '':
		%LineEdit.text = text
	%LineEdit.editable = user_editable
	

func export_settings() -> String:
	return %LineEdit.text

func _on_menu_item_pressed(id: int) -> void:
	var selection = %MenuButton.get_popup().get_item_text(id)
	match selection:
		"Delete Entry":
			queue_free()
