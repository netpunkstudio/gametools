@tool
extends Control

# --- ProjectSettings keys ---
const _PS_VERSION_PATH := "gametools/save/version_file_path"
const _PS_MAX_SLOTS := "gametools/save/max_slots"
const _PS_USE_ENCRYPTION := "gametools/save/use_encryption"
const _PS_ENCRYPTION_KEY := "gametools/save/encryption_key"
const _PS_GAMEPLAY_KEYS := "gametools/options/gameplay_keys"
const _PS_ACCESSIBILITY_KEYS := "gametools/options/accessibility_keys"
const _PS_BG_META_KEY := "gametools/loading/background_meta_key"
const _PS_BG_DEFAULT := "gametools/loading/default_background"
const _PS_BG_KEYS := "gametools/loading/background_keys"
const _PS_BG_PATHS := "gametools/loading/background_paths"
const _PS_TRANSITION_TYPE := "gametools/loading/transition_type"
const _PS_TRANSITION_DUR_IN := "gametools/loading/transition_duration_in"
const _PS_TRANSITION_DUR_OUT := "gametools/loading/transition_duration_out"
const _PS_SLIDE_DIR := "gametools/loading/slide_direction"
const _PS_SHADER_PATH := "gametools/loading/transition_shader"
const _PS_MODS_PATH := "gametools/mods/mods_path"

# --- Save section ---
var _version_path_edit: LineEdit
var _max_slots_spin: SpinBox
var _encryption_check: CheckBox
var _encryption_key_row: HBoxContainer
var _encryption_key_edit: LineEdit
var _encryption_warning: Label
var _gameplay_list: VBoxContainer
var _accessibility_list: VBoxContainer

# --- Loading section ---
var _bg_meta_key_edit: LineEdit
var _bg_default_edit: LineEdit
var _bg_list: VBoxContainer
var _transition_type_btn: OptionButton
var _transition_dur_in_row: HBoxContainer
var _transition_dur_in_spin: SpinBox
var _transition_dur_out_row: HBoxContainer
var _transition_dur_out_spin: SpinBox
var _slide_dir_row: HBoxContainer
var _slide_dir_btn: OptionButton
var _shader_path_row: HBoxContainer
var _shader_path_edit: LineEdit

# --- Mods section ---
var _mods_path_edit: LineEdit

# --- Shared file dialog ---
var _file_dialog: EditorFileDialog
var _pending_file_cb: Callable


func _ready() -> void:
	_ensure_project_settings()
	_build_ui()
	_refresh()


func _ensure_project_settings() -> void:
	# Save
	if not ProjectSettings.has_setting(_PS_VERSION_PATH):
		ProjectSettings.set_setting(_PS_VERSION_PATH, "res://version.json")
	ProjectSettings.add_property_info({
		"name": _PS_VERSION_PATH, "type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE, "hint_string": "*.json",
	})
	if not ProjectSettings.has_setting(_PS_MAX_SLOTS):
		ProjectSettings.set_setting(_PS_MAX_SLOTS, 3)
	ProjectSettings.add_property_info({
		"name": _PS_MAX_SLOTS, "type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE, "hint_string": "1,99,1",
	})
	if not ProjectSettings.has_setting(_PS_USE_ENCRYPTION):
		ProjectSettings.set_setting(_PS_USE_ENCRYPTION, false)
	ProjectSettings.add_property_info({"name": _PS_USE_ENCRYPTION, "type": TYPE_BOOL})
	if not ProjectSettings.has_setting(_PS_ENCRYPTION_KEY):
		ProjectSettings.set_setting(_PS_ENCRYPTION_KEY, "")
	ProjectSettings.add_property_info({"name": _PS_ENCRYPTION_KEY, "type": TYPE_STRING})

	# Options
	if not ProjectSettings.has_setting(_PS_GAMEPLAY_KEYS):
		ProjectSettings.set_setting(_PS_GAMEPLAY_KEYS, PackedStringArray())
	ProjectSettings.add_property_info({"name": _PS_GAMEPLAY_KEYS, "type": TYPE_PACKED_STRING_ARRAY})
	if not ProjectSettings.has_setting(_PS_ACCESSIBILITY_KEYS):
		ProjectSettings.set_setting(_PS_ACCESSIBILITY_KEYS, PackedStringArray())
	ProjectSettings.add_property_info({"name": _PS_ACCESSIBILITY_KEYS, "type": TYPE_PACKED_STRING_ARRAY})

	# Loading
	if not ProjectSettings.has_setting(_PS_BG_META_KEY):
		ProjectSettings.set_setting(_PS_BG_META_KEY, "chapter")
	ProjectSettings.add_property_info({"name": _PS_BG_META_KEY, "type": TYPE_STRING})
	if not ProjectSettings.has_setting(_PS_BG_DEFAULT):
		ProjectSettings.set_setting(_PS_BG_DEFAULT, "")
	ProjectSettings.add_property_info({
		"name": _PS_BG_DEFAULT, "type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE, "hint_string": "*.png,*.jpg,*.jpeg,*.webp",
	})
	if not ProjectSettings.has_setting(_PS_BG_KEYS):
		ProjectSettings.set_setting(_PS_BG_KEYS, PackedStringArray())
	ProjectSettings.add_property_info({"name": _PS_BG_KEYS, "type": TYPE_PACKED_STRING_ARRAY})
	if not ProjectSettings.has_setting(_PS_BG_PATHS):
		ProjectSettings.set_setting(_PS_BG_PATHS, PackedStringArray())
	ProjectSettings.add_property_info({"name": _PS_BG_PATHS, "type": TYPE_PACKED_STRING_ARRAY})
	if not ProjectSettings.has_setting(_PS_TRANSITION_TYPE):
		ProjectSettings.set_setting(_PS_TRANSITION_TYPE, "none")
	ProjectSettings.add_property_info({"name": _PS_TRANSITION_TYPE, "type": TYPE_STRING})
	if not ProjectSettings.has_setting(_PS_TRANSITION_DUR_IN):
		ProjectSettings.set_setting(_PS_TRANSITION_DUR_IN, 0.4)
	ProjectSettings.add_property_info({
		"name": _PS_TRANSITION_DUR_IN, "type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE, "hint_string": "0.05,5.0,0.05",
	})
	if not ProjectSettings.has_setting(_PS_TRANSITION_DUR_OUT):
		ProjectSettings.set_setting(_PS_TRANSITION_DUR_OUT, 0.4)
	ProjectSettings.add_property_info({
		"name": _PS_TRANSITION_DUR_OUT, "type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE, "hint_string": "0.05,5.0,0.05",
	})
	if not ProjectSettings.has_setting(_PS_SLIDE_DIR):
		ProjectSettings.set_setting(_PS_SLIDE_DIR, "left")
	ProjectSettings.add_property_info({"name": _PS_SLIDE_DIR, "type": TYPE_STRING})
	if not ProjectSettings.has_setting(_PS_SHADER_PATH):
		ProjectSettings.set_setting(_PS_SHADER_PATH, "")
	ProjectSettings.add_property_info({
		"name": _PS_SHADER_PATH, "type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE, "hint_string": "*.gdshader,*.shader",
	})

	# Mods
	if not ProjectSettings.has_setting(_PS_MODS_PATH):
		ProjectSettings.set_setting(_PS_MODS_PATH, "user://mods/")
	ProjectSettings.add_property_info({"name": _PS_MODS_PATH, "type": TYPE_STRING})


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

	# ---- Save System ----
	root.add_child(_section_header("Save System"))

	_version_path_edit = LineEdit.new()
	_version_path_edit.placeholder_text = "res://version.json"
	_version_path_edit.text_changed.connect(_on_version_path_changed)
	var browse_version := Button.new()
	browse_version.text = "..."
	browse_version.tooltip_text = "Browse for version.json"
	browse_version.pressed.connect(func() -> void:
		_open_browse("*.json", func(path: String) -> void:
			_version_path_edit.text = path
			_on_version_path_changed(path)))
	root.add_child(_setting_row("Version file", _version_path_edit, browse_version))

	_max_slots_spin = SpinBox.new()
	_max_slots_spin.min_value = 1
	_max_slots_spin.max_value = 99
	_max_slots_spin.step = 1
	_max_slots_spin.value_changed.connect(_on_max_slots_changed)
	root.add_child(_setting_row("Max slots", _max_slots_spin))

	_encryption_check = CheckBox.new()
	_encryption_check.text = "Use encryption"
	_encryption_check.toggled.connect(_on_encryption_toggled)
	root.add_child(_encryption_check)

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

	# ---- Gameplay Keys ----
	root.add_child(_section_header("Gameplay Setting Keys"))
	root.add_child(_hint_label("Stored but not auto-applied. Handle via OptionsManager.setting_changed."))

	_gameplay_list = VBoxContainer.new()
	_gameplay_list.add_theme_constant_override("separation", 4)
	root.add_child(_gameplay_list)

	var add_gameplay := Button.new()
	add_gameplay.text = "+ Add Key"
	add_gameplay.alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_gameplay.flat = true
	add_gameplay.pressed.connect(func() -> void: _add_key_row(_gameplay_list, "", "gameplay"))
	root.add_child(add_gameplay)

	root.add_child(HSeparator.new())

	# ---- Accessibility Keys ----
	root.add_child(_section_header("Accessibility Setting Keys"))
	root.add_child(_hint_label("Stored but not auto-applied. Handle via OptionsManager.setting_changed."))

	_accessibility_list = VBoxContainer.new()
	_accessibility_list.add_theme_constant_override("separation", 4)
	root.add_child(_accessibility_list)

	var add_accessibility := Button.new()
	add_accessibility.text = "+ Add Key"
	add_accessibility.alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_accessibility.flat = true
	add_accessibility.pressed.connect(func() -> void: _add_key_row(_accessibility_list, "", "accessibility"))
	root.add_child(add_accessibility)

	root.add_child(HSeparator.new())

	# ---- Loading Screen ----
	root.add_child(_section_header("Loading Screen"))

	_bg_meta_key_edit = LineEdit.new()
	_bg_meta_key_edit.placeholder_text = "chapter"
	_bg_meta_key_edit.text_changed.connect(func(v: String) -> void:
		ProjectSettings.set_setting(_PS_BG_META_KEY, v)
		ProjectSettings.save())
	root.add_child(_setting_row("Meta key", _bg_meta_key_edit))
	root.add_child(_hint_label("Save metadata key used to look up a background image."))

	_bg_default_edit = LineEdit.new()
	_bg_default_edit.placeholder_text = "res://..."
	_bg_default_edit.text_changed.connect(func(v: String) -> void:
		ProjectSettings.set_setting(_PS_BG_DEFAULT, v)
		ProjectSettings.save())
	var browse_default := Button.new()
	browse_default.text = "..."
	browse_default.pressed.connect(func() -> void:
		_open_browse("*.png,*.jpg,*.jpeg,*.webp", func(path: String) -> void:
			_bg_default_edit.text = path
			ProjectSettings.set_setting(_PS_BG_DEFAULT, path)
			ProjectSettings.save()))
	root.add_child(_setting_row("Default image", _bg_default_edit, browse_default))

	root.add_child(_section_header("Background Mappings"))
	root.add_child(_hint_label("Map save metadata values to background images."))

	_bg_list = VBoxContainer.new()
	_bg_list.add_theme_constant_override("separation", 4)
	root.add_child(_bg_list)

	var add_bg := Button.new()
	add_bg.text = "+ Add Mapping"
	add_bg.alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_bg.flat = true
	add_bg.pressed.connect(func() -> void: _add_bg_row("", ""))
	root.add_child(add_bg)

	root.add_child(HSeparator.new())

	# ---- Transition ----
	root.add_child(_section_header("Transition"))

	_transition_type_btn = OptionButton.new()
	_transition_type_btn.add_item("None")
	_transition_type_btn.add_item("Fade")
	_transition_type_btn.add_item("Slide")
	_transition_type_btn.add_item("Shader")
	_transition_type_btn.item_selected.connect(_on_transition_type_changed)
	root.add_child(_setting_row("Type", _transition_type_btn))

	_transition_dur_in_spin = SpinBox.new()
	_transition_dur_in_spin.min_value = 0.05
	_transition_dur_in_spin.max_value = 5.0
	_transition_dur_in_spin.step = 0.05
	_transition_dur_in_spin.value_changed.connect(func(v: float) -> void:
		ProjectSettings.set_setting(_PS_TRANSITION_DUR_IN, v)
		ProjectSettings.save())
	_transition_dur_in_row = _setting_row("Duration in", _transition_dur_in_spin)
	root.add_child(_transition_dur_in_row)

	_transition_dur_out_spin = SpinBox.new()
	_transition_dur_out_spin.min_value = 0.05
	_transition_dur_out_spin.max_value = 5.0
	_transition_dur_out_spin.step = 0.05
	_transition_dur_out_spin.value_changed.connect(func(v: float) -> void:
		ProjectSettings.set_setting(_PS_TRANSITION_DUR_OUT, v)
		ProjectSettings.save())
	_transition_dur_out_row = _setting_row("Duration out", _transition_dur_out_spin)
	root.add_child(_transition_dur_out_row)

	_slide_dir_btn = OptionButton.new()
	for d: String in ["Left", "Right", "Up", "Down"]:
		_slide_dir_btn.add_item(d)
	_slide_dir_btn.item_selected.connect(_on_slide_dir_changed)
	_slide_dir_row = _setting_row("Direction", _slide_dir_btn)
	root.add_child(_slide_dir_row)

	_shader_path_edit = LineEdit.new()
	_shader_path_edit.placeholder_text = "res://..."
	_shader_path_edit.text_changed.connect(func(v: String) -> void:
		ProjectSettings.set_setting(_PS_SHADER_PATH, v)
		ProjectSettings.save())
	var browse_shader := Button.new()
	browse_shader.text = "..."
	browse_shader.pressed.connect(func() -> void:
		_open_browse("*.gdshader,*.shader", func(path: String) -> void:
			_shader_path_edit.text = path
			ProjectSettings.set_setting(_PS_SHADER_PATH, path)
			ProjectSettings.save()))
	_shader_path_row = _setting_row("Shader", _shader_path_edit, browse_shader)
	root.add_child(_shader_path_row)

	root.add_child(HSeparator.new())

	# ---- Mods ----
	root.add_child(_section_header("Mods"))
	root.add_child(_hint_label(
		"Directory scanned for .pck mods at startup. Use user://mods/ for player-installed mods. " +
		"For Steam Workshop, call ModManager.scan_path() with the workshop item directory at runtime."))

	_mods_path_edit = LineEdit.new()
	_mods_path_edit.placeholder_text = "user://mods/"
	_mods_path_edit.text_changed.connect(func(v: String) -> void:
		ProjectSettings.set_setting(_PS_MODS_PATH, v)
		ProjectSettings.save())
	root.add_child(_setting_row("Mods path", _mods_path_edit))

	# Single file dialog for all browse actions.
	_file_dialog = EditorFileDialog.new()
	_file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	_file_dialog.file_selected.connect(_on_file_selected)
	add_child(_file_dialog)


# ---- Helpers ----

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


func _open_browse(filter: String, callback: Callable) -> void:
	_pending_file_cb = callback
	_file_dialog.clear_filters()
	_file_dialog.add_filter(filter)
	_file_dialog.popup_centered_ratio(0.6)


func _on_file_selected(path: String) -> void:
	if _pending_file_cb.is_valid():
		_pending_file_cb.call(path)
		_pending_file_cb = Callable()


# ---- Refresh ----

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

	_bg_meta_key_edit.text = ProjectSettings.get_setting(_PS_BG_META_KEY, "chapter")
	_bg_default_edit.text = ProjectSettings.get_setting(_PS_BG_DEFAULT, "")

	for child in _bg_list.get_children():
		child.queue_free()
	var bg_keys: PackedStringArray = ProjectSettings.get_setting(_PS_BG_KEYS, PackedStringArray())
	var bg_paths: PackedStringArray = ProjectSettings.get_setting(_PS_BG_PATHS, PackedStringArray())
	for i in mini(bg_keys.size(), bg_paths.size()):
		_add_bg_row(bg_keys[i], bg_paths[i])

	var type_str: String = ProjectSettings.get_setting(_PS_TRANSITION_TYPE, "none")
	_transition_type_btn.select(_type_str_to_index(type_str))
	_transition_dur_in_spin.value = ProjectSettings.get_setting(_PS_TRANSITION_DUR_IN, 0.4)
	_transition_dur_out_spin.value = ProjectSettings.get_setting(_PS_TRANSITION_DUR_OUT, 0.4)

	var dir_str: String = ProjectSettings.get_setting(_PS_SLIDE_DIR, "left")
	_slide_dir_btn.select(_dir_str_to_index(dir_str))
	_shader_path_edit.text = ProjectSettings.get_setting(_PS_SHADER_PATH, "")

	_update_transition_visibility()

	_mods_path_edit.text = ProjectSettings.get_setting(_PS_MODS_PATH, "user://mods/")


# ---- Save / gameplay / accessibility key rows ----

func _add_key_row(list: VBoxContainer, key: String, category: String) -> void:
	var row := HBoxContainer.new()
	list.add_child(row)

	var edit := LineEdit.new()
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit.placeholder_text = "setting_key"
	edit.text = key
	edit.text_changed.connect(func(_v: String) -> void: _save_keys(list, category))
	row.add_child(edit)

	var remove_btn := Button.new()
	remove_btn.text = "×"
	remove_btn.flat = true
	remove_btn.pressed.connect(func() -> void:
		row.queue_free()
		_save_keys(list, category))
	row.add_child(remove_btn)


func _save_keys(list: VBoxContainer, category: String) -> void:
	var keys := PackedStringArray()
	for row in list.get_children():
		if row.is_queued_for_deletion():
			continue
		var k := (row.get_child(0) as LineEdit).text.strip_edges()
		if not k.is_empty():
			keys.append(k)
	var setting := _PS_GAMEPLAY_KEYS if category == "gameplay" else _PS_ACCESSIBILITY_KEYS
	ProjectSettings.set_setting(setting, keys)
	ProjectSettings.save()


# ---- Background mapping rows ----

func _add_bg_row(key: String, path: String) -> void:
	var row := HBoxContainer.new()
	_bg_list.add_child(row)

	var key_edit := LineEdit.new()
	key_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	key_edit.placeholder_text = "meta value"
	key_edit.text = key
	key_edit.text_changed.connect(func(_v: String) -> void: _save_backgrounds())
	row.add_child(key_edit)

	var path_edit := LineEdit.new()
	path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	path_edit.placeholder_text = "res://..."
	path_edit.text = path
	path_edit.text_changed.connect(func(_v: String) -> void: _save_backgrounds())
	row.add_child(path_edit)

	var browse_btn := Button.new()
	browse_btn.text = "..."
	browse_btn.pressed.connect(func() -> void:
		_open_browse("*.png,*.jpg,*.jpeg,*.webp", func(p: String) -> void:
			path_edit.text = p
			_save_backgrounds()))
	row.add_child(browse_btn)

	var remove_btn := Button.new()
	remove_btn.text = "×"
	remove_btn.flat = true
	remove_btn.pressed.connect(func() -> void:
		row.queue_free()
		_save_backgrounds())
	row.add_child(remove_btn)


func _save_backgrounds() -> void:
	var keys := PackedStringArray()
	var paths := PackedStringArray()
	for row in _bg_list.get_children():
		if row.is_queued_for_deletion():
			continue
		var k := (row.get_child(0) as LineEdit).text.strip_edges()
		var p := (row.get_child(1) as LineEdit).text.strip_edges()
		if not k.is_empty():
			keys.append(k)
			paths.append(p)
	ProjectSettings.set_setting(_PS_BG_KEYS, keys)
	ProjectSettings.set_setting(_PS_BG_PATHS, paths)
	ProjectSettings.save()


# ---- Transition callbacks ----

func _on_transition_type_changed(_index: int) -> void:
	ProjectSettings.set_setting(_PS_TRANSITION_TYPE, _type_index_to_str(_index))
	ProjectSettings.save()
	_update_transition_visibility()


func _on_slide_dir_changed(index: int) -> void:
	ProjectSettings.set_setting(_PS_SLIDE_DIR, _dir_index_to_str(index))
	ProjectSettings.save()


func _update_transition_visibility() -> void:
	var type := _type_index_to_str(_transition_type_btn.selected)
	var has_duration := type != "none"
	_transition_dur_in_row.visible = has_duration
	_transition_dur_out_row.visible = has_duration
	_slide_dir_row.visible = type == "slide"
	_shader_path_row.visible = type == "shader"


func _type_str_to_index(s: String) -> int:
	match s:
		"fade":   return 1
		"slide":  return 2
		"shader": return 3
		_:        return 0


func _type_index_to_str(i: int) -> String:
	match i:
		1: return "fade"
		2: return "slide"
		3: return "shader"
		_: return "none"


func _dir_str_to_index(s: String) -> int:
	match s:
		"right": return 1
		"up":    return 2
		"down":  return 3
		_:       return 0  # left


func _dir_index_to_str(i: int) -> String:
	match i:
		1: return "right"
		2: return "up"
		3: return "down"
		_: return "left"


# ---- Save section callbacks ----

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
