@tool
extends Control

const _PS_VERSION_PATH := "gametools/save/version_file_path"
const _PS_MAX_SLOTS := "gametools/save/max_slots"
const _PS_USE_ENCRYPTION := "gametools/save/use_encryption"
const _PS_ENCRYPTION_KEY := "gametools/save/encryption_key"
const _PS_GAMEPLAY_KEYS := "gametools/options/gameplay_keys"
const _PS_ACCESSIBILITY_KEYS := "gametools/options/accessibility_keys"

var _version_path_edit: LineEdit
var _max_slots_spin: SpinBox
var _encryption_check: CheckBox
var _encryption_key_row: HBoxContainer
var _encryption_key_edit: LineEdit
var _encryption_warning: Label
var _gameplay_list: VBoxContainer
var _accessibility_list: VBoxContainer
var _file_dialog: EditorFileDialog


func _ready() -> void:
	_ensure_project_settings()
	_build_ui()
	_refresh()


func _ensure_project_settings() -> void:
	if not ProjectSettings.has_setting(_PS_VERSION_PATH):
		ProjectSettings.set_setting(_PS_VERSION_PATH, "res://version.json")
	ProjectSettings.add_property_info({
		"name": _PS_VERSION_PATH,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "*.json",
	})
	if not ProjectSettings.has_setting(_PS_MAX_SLOTS):
		ProjectSettings.set_setting(_PS_MAX_SLOTS, 3)
	ProjectSettings.add_property_info({
		"name": _PS_MAX_SLOTS,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "1,99,1",
	})
	if not ProjectSettings.has_setting(_PS_USE_ENCRYPTION):
		ProjectSettings.set_setting(_PS_USE_ENCRYPTION, false)
	ProjectSettings.add_property_info({
		"name": _PS_USE_ENCRYPTION,
		"type": TYPE_BOOL,
	})
	if not ProjectSettings.has_setting(_PS_ENCRYPTION_KEY):
		ProjectSettings.set_setting(_PS_ENCRYPTION_KEY, "")
	ProjectSettings.add_property_info({
		"name": _PS_ENCRYPTION_KEY,
		"type": TYPE_STRING,
	})
	if not ProjectSettings.has_setting(_PS_GAMEPLAY_KEYS):
		ProjectSettings.set_setting(_PS_GAMEPLAY_KEYS, PackedStringArray())
	ProjectSettings.add_property_info({
		"name": _PS_GAMEPLAY_KEYS,
		"type": TYPE_PACKED_STRING_ARRAY,
	})
	if not ProjectSettings.has_setting(_PS_ACCESSIBILITY_KEYS):
		ProjectSettings.set_setting(_PS_ACCESSIBILITY_KEYS, PackedStringArray())
	ProjectSettings.add_property_info({
		"name": _PS_ACCESSIBILITY_KEYS,
		"type": TYPE_PACKED_STRING_ARRAY,
	})


func _build_ui() -> void:
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 8)
	scroll.add_child(margin)

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)

	var title := Label.new()
	title.text = "GameTools"
	title.add_theme_font_size_override("font_size", 16)
	root.add_child(title)
	root.add_child(HSeparator.new())

	# --- Save System ---
	root.add_child(_section_header("Save System"))

	# Version file
	_version_path_edit = LineEdit.new()
	_version_path_edit.placeholder_text = "res://version.json"
	_version_path_edit.text_changed.connect(_on_version_path_changed)
	var browse_btn := Button.new()
	browse_btn.text = "..."
	browse_btn.tooltip_text = "Browse for version.json"
	browse_btn.pressed.connect(_open_file_dialog)
	var version_row := _setting_row("Version file", _version_path_edit, browse_btn)
	root.add_child(version_row)

	# Max slots
	_max_slots_spin = SpinBox.new()
	_max_slots_spin.min_value = 1
	_max_slots_spin.max_value = 99
	_max_slots_spin.step = 1
	_max_slots_spin.value_changed.connect(_on_max_slots_changed)
	root.add_child(_setting_row("Max slots", _max_slots_spin))

	# Use encryption
	_encryption_check = CheckBox.new()
	_encryption_check.text = "Use encryption"
	_encryption_check.toggled.connect(_on_encryption_toggled)
	root.add_child(_encryption_check)

	# Encryption key (shown only when encryption is on)
	_encryption_key_edit = LineEdit.new()
	_encryption_key_edit.secret = true
	_encryption_key_edit.placeholder_text = "passphrase"
	_encryption_key_edit.text_changed.connect(_on_encryption_key_changed)
	_encryption_key_row = _setting_row("Key", _encryption_key_edit)
	root.add_child(_encryption_key_row)

	_encryption_warning = _hint_label(
		"⚠ Stored in project.godot. Do not commit a production key — set it at runtime instead.")
	root.add_child(_encryption_warning)

	root.add_child(HSeparator.new())

	# --- Gameplay Keys ---
	root.add_child(_section_header("Gameplay Setting Keys"))
	root.add_child(_hint_label(
		"Stored but not auto-applied. Handle via OptionsManager.setting_changed."))

	_gameplay_list = VBoxContainer.new()
	_gameplay_list.add_theme_constant_override("separation", 4)
	root.add_child(_gameplay_list)

	var add_gameplay := Button.new()
	add_gameplay.text = "+ Add Key"
	add_gameplay.alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_gameplay.flat = true
	add_gameplay.pressed.connect(func(): _add_key_row(_gameplay_list, "", "gameplay"))
	root.add_child(add_gameplay)

	root.add_child(HSeparator.new())

	# --- Accessibility Keys ---
	root.add_child(_section_header("Accessibility Setting Keys"))
	root.add_child(_hint_label(
		"Stored but not auto-applied. Handle via OptionsManager.setting_changed."))

	_accessibility_list = VBoxContainer.new()
	_accessibility_list.add_theme_constant_override("separation", 4)
	root.add_child(_accessibility_list)

	var add_accessibility := Button.new()
	add_accessibility.text = "+ Add Key"
	add_accessibility.alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_accessibility.flat = true
	add_accessibility.pressed.connect(func(): _add_key_row(_accessibility_list, "", "accessibility"))
	root.add_child(add_accessibility)

	# EditorFileDialog must be in the scene tree to work.
	_file_dialog = EditorFileDialog.new()
	_file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	_file_dialog.add_filter("*.json", "JSON Files")
	_file_dialog.file_selected.connect(_on_file_selected)
	add_child(_file_dialog)


# Returns an HBoxContainer with a fixed-width label, the main control expanded,
# and an optional trailing widget (e.g. a browse button).
func _setting_row(label_text: String, control: Control,
		trailing: Control = null) -> HBoxContainer:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 90
	row.add_child(label)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)
	if trailing:
		row.add_child(trailing)
	return row


func _section_header(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 13)
	return label


func _hint_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
	return label


func _refresh() -> void:
	_version_path_edit.text = ProjectSettings.get_setting(_PS_VERSION_PATH, "res://version.json")
	_max_slots_spin.value = ProjectSettings.get_setting(_PS_MAX_SLOTS, 3)

	var use_enc: bool = ProjectSettings.get_setting(_PS_USE_ENCRYPTION, false)
	_encryption_check.button_pressed = use_enc
	_encryption_key_edit.text = ProjectSettings.get_setting(_PS_ENCRYPTION_KEY, "")
	_encryption_key_row.visible = use_enc
	_encryption_warning.visible = use_enc

	for child in _gameplay_list.get_children():
		child.queue_free()
	for key: String in ProjectSettings.get_setting(_PS_GAMEPLAY_KEYS, PackedStringArray()):
		_add_key_row(_gameplay_list, key, "gameplay")

	for child in _accessibility_list.get_children():
		child.queue_free()
	for key: String in ProjectSettings.get_setting(_PS_ACCESSIBILITY_KEYS, PackedStringArray()):
		_add_key_row(_accessibility_list, key, "accessibility")


func _add_key_row(list: VBoxContainer, key: String, category: String) -> void:
	var row := HBoxContainer.new()
	list.add_child(row)

	var edit := LineEdit.new()
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit.placeholder_text = "setting_key"
	edit.text = key
	edit.text_changed.connect(func(_v: String): _save_keys(list, category))
	row.add_child(edit)

	var remove_btn := Button.new()
	remove_btn.text = "×"
	remove_btn.flat = true
	remove_btn.pressed.connect(func():
		row.queue_free()
		_save_keys(list, category))
	row.add_child(remove_btn)


func _save_keys(list: VBoxContainer, category: String) -> void:
	var keys := PackedStringArray()
	for row in list.get_children():
		if row.is_queued_for_deletion():
			continue
		var edit: LineEdit = row.get_child(0)
		var k := edit.text.strip_edges()
		if not k.is_empty():
			keys.append(k)
	var setting := _PS_GAMEPLAY_KEYS if category == "gameplay" else _PS_ACCESSIBILITY_KEYS
	ProjectSettings.set_setting(setting, keys)
	ProjectSettings.save()


func _on_version_path_changed(new_text: String) -> void:
	ProjectSettings.set_setting(_PS_VERSION_PATH, new_text)
	ProjectSettings.save()


func _on_max_slots_changed(value: float) -> void:
	ProjectSettings.set_setting(_PS_MAX_SLOTS, int(value))
	ProjectSettings.save()


func _on_encryption_toggled(enabled: bool) -> void:
	_encryption_key_row.visible = enabled
	_encryption_warning.visible = enabled
	ProjectSettings.set_setting(_PS_USE_ENCRYPTION, enabled)
	ProjectSettings.save()


func _on_encryption_key_changed(new_text: String) -> void:
	ProjectSettings.set_setting(_PS_ENCRYPTION_KEY, new_text)
	ProjectSettings.save()


func _open_file_dialog() -> void:
	_file_dialog.current_path = _version_path_edit.text
	_file_dialog.popup_centered_ratio(0.6)


func _on_file_selected(path: String) -> void:
	_version_path_edit.text = path
	_on_version_path_changed(path)
